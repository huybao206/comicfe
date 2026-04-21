import 'package:flutter/material.dart';

import '../model/guild.dart';
import 'guild_info_chip.dart';

class GuildDetailHeader extends StatelessWidget {
  const GuildDetailHeader({
    super.key,
    required this.guild,
  });

  final Guild guild;

  @override
  Widget build(BuildContext context) {
    final logoUrl = guild.logoUrl;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B1E12),
            Color(0xFF17110C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7A5A26)),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF7B5C28)),
              color: const Color(0xFF21170F),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: (logoUrl ?? '').isNotEmpty
                  ? Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _LogoFallback(),
              )
                  : const _LogoFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guild.name,
                  style: const TextStyle(
                    color: Color(0xFFF8E6B5),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                if (guild.slug.isNotEmpty)
                  Text(
                    guild.slug,
                    style: const TextStyle(
                      color: Color(0xFFD7C39A),
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GuildInfoChip(
                      icon: Icons.star_outline_rounded,
                      text: 'Lv ${guild.level ?? 0}',
                    ),
                    GuildInfoChip(
                      icon: Icons.bolt_outlined,
                      text: 'Power ${guild.guildPower ?? 0}',
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

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.groups_rounded,
        size: 34,
        color: Color(0xFFE0B85C),
      ),
    );
  }
}