import 'package:flutter/material.dart';

import '../model/ranking_entry.dart';

class RankingUserTile extends StatelessWidget {
  const RankingUserTile({
    super.key,
    required this.entry,
  });

  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    final isTop1 = entry.rank == 1;
    final isTop2 = entry.rank == 2;
    final isTop3 = entry.rank == 3;

    Color badgeColor = const Color(0xFFE0B85C);
    if (isTop1) badgeColor = const Color(0xFFFFD76A);
    if (isTop2) badgeColor = const Color(0xFFC7D2E0);
    if (isTop3) badgeColor = const Color(0xFFD7A26B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTop1
              ? const Color(0xFFC7962F)
              : const Color(0xFF735624),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF23180F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF5E451D)),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2B1E12),
            backgroundImage: (entry.avatarUrl ?? '').isNotEmpty
                ? NetworkImage(entry.avatarUrl!)
                : null,
            child: (entry.avatarUrl ?? '').isEmpty
                ? const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFFE0B85C),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: Color(0xFFE8D7B3),
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                if ((entry.subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle!,
                    style: const TextStyle(
                      color: Color(0xFFB89E70),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              color: Color(0xFFF6E7BE),
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
            ),
          ),
        ],
      ),
    );
  }
}