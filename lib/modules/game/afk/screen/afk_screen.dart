import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../user/provider/user_provider.dart';
import '../model/afk_session.dart';
import '../provider/afk_provider.dart';
import '../widgets/afk_header.dart';
import '../widgets/afk_result_card.dart';
import '../widgets/afk_section_title.dart';
import '../widgets/afk_session_card.dart';

class AfkScreen extends StatefulWidget {
  const AfkScreen({super.key});

  @override
  State<AfkScreen> createState() => _AfkScreenState();
}

class _AfkScreenState extends State<AfkScreen> {
  Timer? _timer;

  int? _localRunningSessionId;
  DateTime? _localRunningSeenAt;
  int _localRunningBaseSeconds = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AfkProvider>().bootstrap();
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<AfkProvider>().bootstrap();
  }

  Future<void> _startAfk() async {
    final provider = context.read<AfkProvider>();
    final ok = await provider.startSession();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Bắt đầu tu luyện AFK thành công'
              : (provider.errorMessage ?? 'Không thể bắt đầu AFK'),
        ),
      ),
    );
  }

  Future<void> _finishAfk() async {
    final provider = context.read<AfkProvider>();
    final sessionId = provider.activeSession?.id ?? 0;

    if (sessionId <= 0) return;

    final ok = await provider.finishSession(sessionId: sessionId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Đã kết thúc phiên AFK'
              : (provider.errorMessage ?? 'Kết thúc AFK thất bại'),
        ),
      ),
    );
  }

  Future<void> _claimAfk() async {
    final afkProvider = context.read<AfkProvider>();
    final sessionId = afkProvider.activeSession?.id ?? 0;

    if (sessionId <= 0) return;

    final ok = await afkProvider.claimSession(sessionId: sessionId);

    if (!mounted) return;

    if (ok) {
      // Cập nhật lại dữ liệu hồ sơ để EXP / vàng lên ngay ở màn Tôi
      await context.read<UserProvider>().loadMyProfile();
    }

    if (!mounted) return;

    final result = afkProvider.claimResult;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Nhận ${result?.claimedExp ?? 0} EXP • ${_formatGold(result?.claimedGold ?? 0)} vàng'
              : (afkProvider.errorMessage ?? 'Nhận thưởng thất bại'),
        ),
      ),
    );
  }


  Future<void> _claimAndContinueAfk() async {
    final afkProvider = context.read<AfkProvider>();
    final sessionId = afkProvider.activeSession?.id ?? 0;

    if (sessionId <= 0) return;

    final claimed = await afkProvider.claimSession(sessionId: sessionId);

    if (!mounted) return;

    if (!claimed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(
            afkProvider.errorMessage ?? 'Nhận thưởng thất bại',
          ),
        ),
      );
      return;
    }

    final claimedExp = afkProvider.claimResult?.claimedExp ?? 0;
    final claimedGold = afkProvider.claimResult?.claimedGold ?? 0;

    await context.read<UserProvider>().loadMyProfile();

    if (!mounted) return;

    final started = await afkProvider.startSession();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        started ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          started
              ? 'Đã nhận $claimedExp EXP • ${_formatGold(claimedGold)} vàng và tiếp tục AFK'
              : (afkProvider.errorMessage ?? 'Đã nhận thưởng nhưng chưa thể tiếp tục AFK'),
        ),
      ),
    );
  }

  void _syncLocalRunningSession(AfkSession? session) {
    if (session == null || !session.isRunning) {
      _localRunningSessionId = null;
      _localRunningSeenAt = null;
      _localRunningBaseSeconds = 0;
      return;
    }

    if (_localRunningSessionId == session.id &&
        _localRunningSeenAt != null) {
      return;
    }

    _localRunningSessionId = session.id;
    _localRunningSeenAt = DateTime.now();
    _localRunningBaseSeconds = session.durationSeconds;
  }

  int _localLiveDuration(AfkSession session) {
    _syncLocalRunningSession(session);

    final seenAt = _localRunningSeenAt;

    if (seenAt == null) return session.durationSeconds;

    final localElapsed = DateTime.now().difference(seenAt).inSeconds;
    final localSeconds = _localRunningBaseSeconds +
        (localElapsed < 0 ? 0 : localElapsed);

    return _maxInt(session.durationSeconds, localSeconds);
  }

  int _liveDuration(AfkSession session) {
    if (!session.isRunning) return session.durationSeconds;

    final localSeconds = _localLiveDuration(session);
    final startedAt = session.startedAt;

    if (startedAt == null) return localSeconds;

    final serverSeconds = DateTime.now().difference(startedAt).inSeconds;

    // Nếu giờ backend/DB bị lệch timezone làm startedAt nằm ở tương lai,
    // serverSeconds sẽ âm. Khi đó vẫn dùng đồng hồ local để UI chạy ngay.
    if (serverSeconds <= 0) return localSeconds;

    return _maxInt(localSeconds, serverSeconds);
  }

  int _liveExp(AfkSession session, AfkProvider provider, int seconds) {
    if (!session.isRunning) return session.totalExpEarned;

    final baseExp = (seconds / 60 * provider.expPerMinute).floor();
    final bonusPercent =
        provider.commonBonusPercent + provider.vipBonusPercent;
    final bonusExp = (baseExp * bonusPercent / 100).floor();

    return _maxInt(session.totalExpEarned, baseExp + bonusExp);
  }

  double _liveGold(AfkSession session, AfkProvider provider, int seconds) {
    if (!session.isRunning) return session.totalGoldEarned;

    final baseGold = seconds / 60 * provider.goldPerMinute;
    final bonusPercent =
        provider.commonBonusPercent + provider.vipBonusPercent;
    final bonusGold = baseGold * bonusPercent / 100;
    final totalGold = double.parse((baseGold + bonusGold).toStringAsFixed(2));

    return _maxDouble(session.totalGoldEarned, totalGold);
  }

  int _maxInt(int a, int b) => a > b ? a : b;

  double _maxDouble(double a, double b) => a > b ? a : b;

  String _formatGold(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AfkProvider>();
    final session = provider.activeSession;
    _syncLocalRunningSession(session);

    final liveDurationSeconds =
    session == null ? 0 : _liveDuration(session);
    final liveTotalExpEarned = session == null
        ? 0
        : _liveExp(session, provider, liveDurationSeconds);
    final liveTotalGoldEarned = session == null
        ? 0.0
        : _liveGold(session, provider, liveDurationSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: [
            AfkHeader(
              isEnabled: provider.afkEnabled,
              expPerMinute: provider.expPerMinute,
              goldPerMinute: provider.goldPerMinute,
              vipBonusPercent: provider.vipBonusPercent,
              imageUrl: provider.bannerImageUrl,
            ),

            const SizedBox(height: 14),

            if (session != null)
              AfkSessionCard(
                session: session,
                liveDurationSeconds: liveDurationSeconds,
                liveTotalExpEarned: liveTotalExpEarned,
                liveTotalGoldEarned: liveTotalGoldEarned,
                isSubmitting: provider.isSubmitting,
                onFinish: session.isRunning ? _finishAfk : null,
                onClaim: session.canClaim ? _claimAfk : null,
                onClaimAndContinue:
                session.canClaim ? _claimAndContinueAfk : null,
              )
            else
              _StartAfkCard(
                enabled: provider.afkEnabled,
                isSubmitting: provider.isSubmitting,
                onStart: _startAfk,
              ),

            if (provider.claimResult != null) ...[
              const SizedBox(height: 14),
              AfkResultCard(
                title: 'Phần thưởng vừa nhận',
                subtitle: 'Đã cộng trực tiếp vào tài khoản tu luyện.',
                exp: provider.claimResult!.claimedExp,
                gold: provider.claimResult!.claimedGold,
              ),
            ] else if (session != null && session.isFinished) ...[
              const SizedBox(height: 14),
              AfkResultCard(
                title: 'Thưởng phiên AFK',
                subtitle: 'Kết thúc phiên rồi, hãy nhận thưởng.',
                exp: session.totalExpEarned,
                gold: session.totalGoldEarned,
              ),
            ],

            const SizedBox(height: 18),

            const AfkSectionTitle(
              title: 'Cơ chế phần thưởng',
              icon: Icons.auto_awesome_rounded,
              action: 'Từ admin',
            ),

            const SizedBox(height: 10),

            _PolicyGrid(provider: provider),
          ],
        ),
      ),
    );
  }
}

class _StartAfkCard extends StatelessWidget {
  const _StartAfkCard({
    required this.enabled,
    required this.isSubmitting,
    required this.onStart,
  });

  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bắt đầu tu luyện ngoại tuyến',
            style: TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            enabled
                ? 'Khi bật AFK, thời gian sẽ được tính tự động để nhận EXP và vàng.'
                : 'Hệ thống AFK hiện đang bị tắt từ trang quản trị.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              height: 1.45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: !enabled || isSubmitting ? null : onStart,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A02F),
                disabledBackgroundColor: const Color(0xFF3A3F51),
                foregroundColor: const Color(0xFF211407),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              icon: isSubmitting
                  ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF211407),
                ),
              )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                enabled ? 'Bắt đầu AFK' : 'AFK đang tắt',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyGrid extends StatelessWidget {
  const _PolicyGrid({
    required this.provider,
  });

  final AfkProvider provider;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.34,
      children: [
        _PolicyTile(
          icon: Icons.auto_awesome_rounded,
          label: 'EXP / phút',
          value: _formatValue(provider.expPerMinute),
          color: const Color(0xFF8FB0FF),
        ),
        _PolicyTile(
          icon: Icons.monetization_on_outlined,
          label: 'Vàng / phút',
          value: _formatValue(provider.goldPerMinute),
          color: const Color(0xFFFFD27A),
        ),
        _PolicyTile(
          icon: Icons.timer_outlined,
          label: 'Nhận từ',
          value: provider.minMinutesToClaim <= 0
              ? 'Ngay lập tức'
              : '${provider.minMinutesToClaim} phút',
          color: const Color(0xFF4ADE80),
        ),
        _PolicyTile(
          icon: Icons.workspace_premium_outlined,
          label: 'Bonus VIP',
          value: '${_formatValue(provider.vipBonusPercent)}%',
          color: const Color(0xFFFF7AA8),
        ),
        _PolicyTile(
          icon: Icons.hourglass_bottom_rounded,
          label: 'Tối đa / phiên',
          value: '${provider.maxMinutesPerSession} phút',
          color: const Color(0xFFB58CFF),
        ),
        _PolicyTile(
          icon: Icons.calendar_month_outlined,
          label: 'Tối đa / ngày',
          value: '${provider.dailyMaxMinutes} phút',
          color: const Color(0xFF60A5FA),
        ),
      ],
    );
  }

  static String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}