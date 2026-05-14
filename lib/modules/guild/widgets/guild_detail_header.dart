import 'package:flutter/material.dart';

import '../model/guild.dart';

class GuildDetailHeader extends StatelessWidget {
  const GuildDetailHeader({
    super.key,
    required this.guild,
  });

  final Guild guild;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.2,
          colors: [
            Color(0xFF574117),
            Color(0xFF1D140C),
            Color(0xFF070B14),
          ],
          stops: [0, 0.48, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 52,
            right: -52,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A02F).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -72,
            left: -72,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6574FF).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 24,
            child: Column(
              children: [
                _LargeGuildLogo(logoUrl: guild.logoUrl),
                const SizedBox(height: 16),
                _StatusBadge(text: guild.displayStatus),
                const SizedBox(height: 10),
                Text(
                  guild.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  guild.slug.isNotEmpty ? '@${guild.slug}' : 'Tông môn tu tiên',
                  style: TextStyle(
                    color: const Color(0xFFE9D7AE).withOpacity(0.68),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.star_outline_rounded,
                      text: 'Lv ${guild.level ?? 0}',
                      color: const Color(0xFFFFD27A),
                    ),
                    _InfoChip(
                      icon: Icons.bolt_outlined,
                      text: 'Power ${guild.guildPower ?? 0}',
                      color: const Color(0xFF8FB0FF),
                    ),
                    _InfoChip(
                      icon: Icons.person_outline_rounded,
                      text: guild.hasLeader
                          ? guild.leaderName!
                          : 'Chưa có leader',
                      color: const Color(0xFF4ADE80),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeGuildLogo extends StatelessWidget {
  const _LargeGuildLogo({
    required this.logoUrl,
  });

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = logoUrl != null && logoUrl!.trim().isNotEmpty;

    return Container(
      width: 124,
      height: 124,
      padding: const EdgeInsets.all(4),
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
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A02F).withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21170F),
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.network(
          logoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return const Center(
      child: Icon(
        Icons.groups_rounded,
        size: 58,
        color: Color(0xFFE0B85C),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80).withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF4ADE80).withOpacity(0.55),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF86EFAC),
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE9D7AE),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}