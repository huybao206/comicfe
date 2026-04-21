import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/afk_provider.dart';
import '../widgets/afk_config_card.dart';
import '../widgets/afk_empty_view.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AfkProvider>().loadConfigs();
    });
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
              ? 'Bắt đầu AFK thành công'
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
    final provider = context.read<AfkProvider>();
    final sessionId = provider.activeSession?.id ?? 0;
    if (sessionId <= 0) return;

    final ok = await provider.claimSession(sessionId: sessionId);

    if (!mounted) return;

    final exp = provider.claimResult?.claimedExp ?? 0;
    final gold = provider.claimResult?.claimedGold ?? 0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Nhận được $exp EXP • $gold vàng'
              : (provider.errorMessage ?? 'Nhận thưởng thất bại'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AfkProvider>();
    final session = provider.activeSession;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: () => context.read<AfkProvider>().loadConfigs(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const AfkHeader(),
            if (session != null) ...[
              const SizedBox(height: 16),
              AfkSessionCard(
                sessionId: '${session.id}',
                status: session.sessionStatus,
                totalExpEarned: '${session.totalExpEarned}',
                durationSeconds: '${session.durationSeconds}',
                isSubmitting: provider.isSubmitting,
                onFinish: session.sessionStatus == 'running' ? _finishAfk : null,
                onClaim: session.sessionStatus == 'finished' ? _claimAfk : null,
              ),
            ],
            if (provider.claimResult != null) ...[
              const SizedBox(height: 16),
              AfkResultCard(
                title: 'Kết quả nhận thưởng',
                value:
                'EXP: ${provider.claimResult!.claimedExp} • Vàng: ${provider.claimResult!.claimedGold}',
              ),
            ] else if (session != null && session.sessionStatus == 'finished') ...[
              const SizedBox(height: 16),
              AfkResultCard(
                title: 'Kết quả phiên AFK',
                value:
                'Base EXP: ${session.baseExpEarned} • Bonus EXP: ${session.bonusExpEarned} • Total EXP: ${session.totalExpEarned}',
              ),
            ],
            const SizedBox(height: 16),
            const AfkSectionTitle(title: 'Cấu hình AFK'),
            const SizedBox(height: 10),
            if (provider.isLoading && provider.configs.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFC7962F),
                  ),
                ),
              )
            else if (provider.errorMessage != null && provider.configs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Color(0xFFE6D4AC)),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (provider.configs.isEmpty)
                const AfkEmptyView()
              else ...[
                  ...provider.configs.map(
                        (config) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AfkConfigCard(config: config),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: provider.isSubmitting || provider.activeSession != null
                          ? null
                          : _startAfk,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC7962F),
                        foregroundColor: const Color(0xFF24170B),
                        disabledBackgroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: provider.isSubmitting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF24170B),
                        ),
                      )
                          : const Icon(Icons.bolt_rounded),
                      label: Text(
                        provider.activeSession != null
                            ? 'Đang có phiên AFK'
                            : 'Bắt đầu tu luyện',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
          ],
        ),
      ),
    );
  }
}