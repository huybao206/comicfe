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
    final accent = _rankColor(entry.rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: entry.rank <= 3
              ? accent.withOpacity(0.62)
              : const Color(0xFF263756),
        ),
      ),
      child: Row(
        children: [
          _RankBadge(
            rank: entry.rank,
            color: accent,
          ),
          const SizedBox(width: 11),
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF18213A),
            backgroundImage: (entry.avatarUrl ?? '').trim().isNotEmpty
                ? NetworkImage(entry.avatarUrl!)
                : null,
            child: (entry.avatarUrl ?? '').trim().isEmpty
                ? Icon(
              Icons.person_outline_rounded,
              color: accent,
              size: 24,
            )
                : null,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.displayScore}',
                style: const TextStyle(
                  color: Color(0xFFFFE9B0),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'điểm',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.42),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD27A);
    if (rank == 2) return const Color(0xFFC7D2E0);
    if (rank == 3) return const Color(0xFFD7A26B);

    return const Color(0xFF8FB0FF);
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.color,
  });

  final int rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}