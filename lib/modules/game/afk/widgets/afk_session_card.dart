import 'package:flutter/material.dart';

class AfkSessionCard extends StatelessWidget {
  const AfkSessionCard({
    super.key,
    required this.sessionId,
    required this.status,
    required this.totalExpEarned,
    required this.durationSeconds,
    required this.isSubmitting,
    required this.onFinish,
    required this.onClaim,
  });

  final String sessionId;
  final String status;
  final String totalExpEarned;
  final String durationSeconds;
  final bool isSubmitting;
  final VoidCallback? onFinish;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phiên AFK hiện tại',
            style: TextStyle(
              color: Color(0xFFF6E7BE),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _InfoLine(label: 'Session ID', value: sessionId),
          _InfoLine(label: 'Trạng thái', value: status),
          _InfoLine(label: 'Thời lượng', value: '$durationSeconds giây'),
          _InfoLine(label: 'Tổng EXP', value: totalExpEarned),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : onFinish,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE8D7B3),
                    side: const BorderSide(color: Color(0xFF735624)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Kết thúc',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isSubmitting ? null : onClaim,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC7962F),
                    foregroundColor: const Color(0xFF24170B),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
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
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB89E70),
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFFE8D7B3),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}