import 'package:flutter/material.dart';

import '../model/afk_session.dart';

class AfkSessionCard extends StatelessWidget {
  const AfkSessionCard({
    super.key,
    required this.session,
    required this.liveDurationSeconds,
    required this.isSubmitting,
    required this.onFinish,
    required this.onClaim,
  });

  final AfkSession session;
  final int liveDurationSeconds;
  final bool isSubmitting;
  final VoidCallback? onFinish;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final statusColor = session.isRunning
        ? const Color(0xFF4ADE80)
        : const Color(0xFFFFD27A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withOpacity(0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.40)),
                ),
                child: Icon(
                  session.isRunning
                      ? Icons.hourglass_top_rounded
                      : Icons.card_giftcard_rounded,
                  color: statusColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phiên AFK hiện tại',
                      style: TextStyle(
                        color: Color(0xFFFFE9B0),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.isRunning
                          ? 'Đang tích lũy phần thưởng'
                          : 'Đã kết thúc, có thể nhận thưởng',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.54),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(
                label: session.isRunning ? 'Đang chạy' : 'Đã xong',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'Thời gian',
                  value: _formatDuration(liveDurationSeconds),
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFF8FB0FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: 'Tổng EXP',
                  value: '${session.totalExpEarned}',
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: 'Tổng vàng',
                  value: _formatGold(session.totalGoldEarned),
                  icon: Icons.monetization_on_outlined,
                  color: const Color(0xFFFFD27A),
                ),
              ),
            ],
          ),
          if (session.isFinished) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SmallReward(
                    label: 'Base EXP',
                    value: '${session.baseExpEarned}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SmallReward(
                    label: 'Bonus EXP',
                    value: '${session.bonusExpEarned}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SmallReward(
                    label: 'Bonus vàng',
                    value: _formatGold(session.bonusGoldEarned),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmitting ? null : onFinish,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE9D7AE),
                    side: const BorderSide(color: Color(0xFF35466E)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text(
                    'Kết thúc',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : onClaim,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A02F),
                    disabledBackgroundColor: const Color(0xFF3A3F51),
                    foregroundColor: const Color(0xFF211407),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.card_giftcard_rounded),
                  label: const Text(
                    'Nhận thưởng',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hour = seconds ~/ 3600;
    final minute = (seconds % 3600) ~/ 60;
    final second = seconds % 60;

    if (hour > 0) {
      return '${hour}h ${minute}m';
    }

    if (minute > 0) {
      return '${minute}m ${second}s';
    }

    return '${second}s';
  }

  static String _formatGold(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.42)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151D31),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 19,
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallReward extends StatelessWidget {
  const _SmallReward({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF151D31),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}