import 'package:flutter/material.dart';

import '../model/ranking_entry.dart';

class RankingMeCard extends StatelessWidget {
  const RankingMeCard({
    super.key,
    required this.entry,
  });

  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF23180F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF5E451D)),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFFE0B85C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thứ hạng của bạn',
                  style: TextStyle(
                    color: Color(0xFFB89E70),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.name} • #${entry.rank}',
                  style: const TextStyle(
                    color: Color(0xFFE8D7B3),
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              color: Color(0xFFF6E7BE),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}