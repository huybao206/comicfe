import 'package:flutter/material.dart';

import '../model/guild_member.dart';

class GuildMemberTile extends StatelessWidget {
  const GuildMemberTile({
    super.key,
    required this.member,
    this.canManageRole = false,
    this.canKick = false,
    this.isSubmitting = false,
    this.onChangeRole,
    this.onKick,
  });

  final GuildMember member;
  final bool canManageRole;
  final bool canKick;
  final bool isSubmitting;
  final ValueChanged<String>? onChangeRole;
  final VoidCallback? onKick;

  @override
  Widget build(BuildContext context) {
    final canEditThisMember = canManageRole && !member.isLeader && onChangeRole != null;
    final canKickThisMember = canKick && !member.isLeader && onKick != null;

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          if (canEditThisMember || canKickThisMember) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              enabled: !isSubmitting,
              tooltip: 'Quản lý thành viên',
              color: const Color(0xFF11182A),
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFFFFD27A)),
              onSelected: (value) {
                if (value == 'kick') {
                  onKick?.call();
                  return;
                }
                onChangeRole?.call(value);
              },
              itemBuilder: (context) => [
                if (canEditThisMember) ...const [
                  PopupMenuItem(
                    value: 'vice_leader',
                    child: Text('Nâng thành Phó bang', style: TextStyle(color: Color(0xFFFFE9B0))),
                  ),
                  PopupMenuItem(
                    value: 'elder',
                    child: Text('Đổi thành Trưởng lão', style: TextStyle(color: Color(0xFFFFE9B0))),
                  ),
                  PopupMenuItem(
                    value: 'member',
                    child: Text('Hạ thành Thành viên', style: TextStyle(color: Color(0xFFFFE9B0))),
                  ),
                ],
                if (canKickThisMember) ...const [
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'kick',
                    child: Text('Kick khỏi bang', style: TextStyle(color: Color(0xFFFF8A8A))),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
