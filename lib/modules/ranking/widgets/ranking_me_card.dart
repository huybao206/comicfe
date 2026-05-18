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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF172345),
            Color(0xFF10182B),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD4A02F).withOpacity(0.58)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD27A),
                  Color(0xFFD4A02F),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_pin_circle_rounded,
              color: Color(0xFF211407),
              size: 31,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thứ hạng của bạn',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.54),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                  ),
                ),
                if (entry.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.52),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A02F).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFD4A02F).withOpacity(0.48),
                  ),
                ),
                child: Text(
                  '#${entry.rank}',
                  style: const TextStyle(
                    color: Color(0xFFFFD27A),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${entry.displayScore}',
                style: const TextStyle(
                  color: Color(0xFFFFE9B0),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                'điểm',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.46),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}