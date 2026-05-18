import 'package:flutter/material.dart';

class AfkHeader extends StatelessWidget {
  const AfkHeader({
    super.key,
    required this.isEnabled,
    required this.expPerMinute,
    required this.goldPerMinute,
    required this.vipBonusPercent,
  });

  final bool isEnabled;
  final double expPerMinute;
  final double goldPerMinute;
  final double vipBonusPercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 196,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF7A5A26)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A02F).withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.25,
                colors: [
                  Color(0xFF574117),
                  Color(0xFF172345),
                  Color(0xFF0B1020),
                ],
                stops: [0, 0.46, 1],
              ),
            ),
          ),
          Positioned(
            top: -44,
            right: -36,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A02F).withOpacity(0.11),
              ),
            ),
          ),
          Positioned(
            bottom: -52,
            left: -42,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6574FF).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            right: 18,
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD27A),
                        Color(0xFFD4A02F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF211407),
                    size: 36,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu luyện AFK',
                        style: TextStyle(
                          color: Color(0xFFFFE9B0),
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isEnabled
                            ? 'Tích lũy EXP và vàng ngay cả khi không thao tác.'
                            : 'Hệ thống AFK đang tạm tắt từ admin.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD7C39A),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: _HeaderStat(
                    label: 'EXP/phút',
                    value: _format(expPerMinute),
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderStat(
                    label: 'Vàng/phút',
                    value: _format(goldPerMinute),
                    icon: Icons.monetization_on_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderStat(
                    label: 'VIP bonus',
                    value: '${_format(vipBonusPercent)}%',
                    icon: Icons.workspace_premium_outlined,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD27A),
            size: 17,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}