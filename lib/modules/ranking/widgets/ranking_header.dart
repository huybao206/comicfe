import 'package:flutter/material.dart';

class RankingHeader extends StatelessWidget {
  const RankingHeader({
    super.key,
    required this.totalEntries,
    required this.topScore,
    required this.selectedTypeName,
  });

  final int totalEntries;
  final int topScore;
  final String selectedTypeName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF7A5A26)),
        gradient: const RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [
            Color(0xFF5C4217),
            Color(0xFF22284F),
            Color(0xFF0B1020),
          ],
          stops: [0, 0.46, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
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
                    Icons.emoji_events_rounded,
                    color: Color(0xFF211407),
                    size: 36,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thiên Kiêu Bảng',
                        style: TextStyle(
                          color: Color(0xFFFFE9B0),
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'So tài cao thủ, tranh phong thứ hạng trong giới tu luyện.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
                    icon: Icons.people_alt_outlined,
                    label: 'Cao thủ',
                    value: '$totalEntries',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderStat(
                    icon: Icons.bolt_outlined,
                    label: 'Top điểm',
                    value: '$topScore',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderStat(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Loại bảng',
                    value: selectedTypeName,
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

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD27A),
            size: 18,
          ),
          const SizedBox(width: 7),
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
                    fontSize: 13.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    height: 1,
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