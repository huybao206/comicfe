import 'package:flutter/material.dart';

import '../model/guild_member.dart';

class GuildMemberTile extends StatelessWidget {
  const GuildMemberTile({
    super.key,
    required this.member,
  });

  final GuildMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF23180F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5E451D)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2B1E12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFFE0B85C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Color(0xFFE8D7B3),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role ?? 'Thành viên',
                  style: const TextStyle(
                    color: Color(0xFFB89E70),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          if (member.contributionPoints != null)
            Text(
              '${member.contributionPoints} điểm',
              style: const TextStyle(
                color: Color(0xFFF6E7BE),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}