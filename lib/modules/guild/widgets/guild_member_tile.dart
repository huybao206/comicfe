import 'package:flutter/material.dart';

import '../model/guild_member.dart';

class GuildMemberTile extends StatelessWidget {
  const GuildMemberTile({
    super.key,
    required this.member,
    this.canManageRole = false,
    this.isSubmitting = false,
    this.onChangeRole,
  });

  final GuildMember member;
  final bool canManageRole;
  final bool isSubmitting;
  final ValueChanged<String>? onChangeRole;

  @override
  Widget build(BuildContext context) {
    final canEditThisMember = canManageRole && !member.isLeader && onChangeRole != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151D31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: member.isLeader
                    ? const [Color(0xFFFFD27A), Color(0xFFC0842F)]
                    : const [Color(0xFF6574FF), Color(0xFF334CFF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              member.isLeader ? Icons.workspace_premium_rounded : Icons.person_outline_rounded,
              color: member.isLeader ? const Color(0xFF211407) : Colors.white,
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
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role ?? 'Thành viên',
                  style: TextStyle(
                    color: member.isLeader
                        ? const Color(0xFFFFD27A)
                        : Colors.white.withOpacity(0.50),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (member.contributionPoints != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A02F).withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFD4A02F).withOpacity(0.38),
                ),
              ),
              child: Text(
                '${member.contributionPoints} điểm',
                style: const TextStyle(
                  color: Color(0xFFFFD27A),
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                ),
              ),
            ),
          if (canEditThisMember) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              enabled: !isSubmitting,
              tooltip: 'Nâng/hạ chức',
              color: const Color(0xFF11182A),
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFFFD27A)),
              onSelected: onChangeRole,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'vice_leader',
                  child: Text('Phó bang', style: TextStyle(color: Color(0xFFFFE9B0))),
                ),
                PopupMenuItem(
                  value: 'elder',
                  child: Text('Trưởng lão', style: TextStyle(color: Color(0xFFFFE9B0))),
                ),
                PopupMenuItem(
                  value: 'member',
                  child: Text('Thành viên', style: TextStyle(color: Color(0xFFFFE9B0))),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
