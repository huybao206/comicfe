import 'package:flutter/material.dart';

import '../model/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF7A5A26)),
        gradient: const RadialGradient(
          center: Alignment.topRight,
          radius: 1.25,
          colors: [
            Color(0xFF574117),
            Color(0xFF172345),
            Color(0xFF0B1020),
          ],
          stops: [0, 0.46, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A02F).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.34),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -42,
            child: Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A02F).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -56,
            left: -48,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6574FF).withOpacity(0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD27A),
                          Color(0xFFD4A02F),
                          Color(0xFF7A5A26),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF151D31),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasAvatar
                          ? Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _avatarFallback(),
                      )
                          : _avatarFallback(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Text(
                              profile.displayName.trim().isNotEmpty
                                  ? profile.displayName
                                  : 'Đạo hữu',
                              style: const TextStyle(
                                color: Color(0xFFFFE9B0),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1.12,
                              ),
                            ),
                            _VipBadge(
                              label: profile.vipDisplayName,
                              active: profile.vipLevel > 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (profile.username.trim().isNotEmpty)
                          Text(
                            '@${profile.username}',
                            style: TextStyle(
                              color: const Color(0xFFE9D7AE)
                                  .withOpacity(0.72),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (profile.email.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            profile.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.48),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 11),
                        SizedBox(
                          height: 38,
                          child: FilledButton.icon(
                            onPressed: onEdit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD4A02F),
                              foregroundColor: const Color(0xFF211407),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.edit_rounded, size: 17),
                            label: const Text(
                              'Sửa hồ sơ',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _MetaPill(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Cấp độ',
                    value: '${profile.level}',
                    color: const Color(0xFFFFD27A),
                  ),
                  const SizedBox(width: 8),
                  _MetaPill(
                    icon: Icons.groups_rounded,
                    title: 'Bang phái',
                    value: profile.hasGuild
                        ? (profile.guildName ?? 'Đã gia nhập')
                        : 'Chưa có',
                    color: const Color(0xFF4ADE80),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Kinh nghiệm',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.54),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${profile.exp}/${profile.expToNextLevel} EXP',
                    style: const TextStyle(
                      color: Color(0xFFFFD27A),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: profile.expProgress,
                  backgroundColor: Colors.white.withOpacity(0.10),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD4A02F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        color: Color(0xFFE0B85C),
        size: 46,
      ),
    );
  }
}

class _VipBadge extends StatelessWidget {
  const _VipBadge({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFD4A02F).withOpacity(0.16)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? const Color(0xFFD4A02F).withOpacity(0.52)
              : Colors.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active
                ? Icons.workspace_premium_rounded
                : Icons.lock_outline_rounded,
            size: 14,
            color: active
                ? const Color(0xFFFFD27A)
                : Colors.white.withOpacity(0.52),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active
                  ? const Color(0xFFFFD27A)
                  : Colors.white.withOpacity(0.52),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.46),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFE9B0),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}