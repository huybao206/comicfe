import 'package:flutter/material.dart';

import '../model/guild.dart';
import '../screens/guild_detail_screen.dart';
import '../screens/guild_screen.dart';
import 'guild_info_chip.dart';

class GuildListCard extends StatelessWidget {
  const GuildListCard({
    super.key,
    required this.guild,
  });

  final Guild guild;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuildDetailScreen(guildId: guild.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF17110C),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF735624)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GuildLogo(logoUrl: guild.logoUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guild.name,
                      style: const TextStyle(
                        color: Color(0xFFF6E7BE),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (guild.description ?? '').trim().isNotEmpty
                          ? guild.description!
                          : 'Tông môn này hiện chưa có mô tả.',
                      style: const TextStyle(
                        color: Color(0xFFD5C6A2),
                        height: 1.5,
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
                        if ((guild.guildStatus ?? '').isNotEmpty)
                          GuildInfoChip(
                            icon: Icons.shield_outlined,
                            text: guild.guildStatus!,
                          ),
                        if ((guild.leaderName ?? '').isNotEmpty)
                          GuildInfoChip(
                            icon: Icons.person_outline_rounded,
                            text: guild.leaderName!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD2B06D),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuildLogo extends StatelessWidget {
  const _GuildLogo({
    required this.logoUrl,
  });

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = logoUrl != null && logoUrl!.trim().isNotEmpty;

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7B5C28)),
        color: const Color(0xFF21170F),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: hasImage
            ? Image.network(
          logoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _GuildLogoFallback(),
        )
            : const _GuildLogoFallback(),
      ),
    );
  }
}

class _GuildLogoFallback extends StatelessWidget {
  const _GuildLogoFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.groups_rounded,
        size: 36,
        color: Color(0xFFE0B85C),
      ),
    );
  }
}