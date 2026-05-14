import 'package:flutter/material.dart';

import '../model/guild.dart';
import '../screens/guild_detail_screen.dart';

class GuildListCard extends StatelessWidget {
  const GuildListCard({
    super.key,
    required this.guild,
  });

  final Guild guild;

  @override
  Widget build(BuildContext context) {
    final powerColor = _powerColor(guild.guildPower ?? 0);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GuildDetailScreen(guildId: guild.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF10182B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: powerColor.withOpacity(0.48)),
            boxShadow: [
              BoxShadow(
                color: powerColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: powerColor.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GuildLogo(
                      logoUrl: guild.logoUrl,
                      accentColor: powerColor,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  guild.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFF6E7BE),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusBadge(
                                text: guild.displayStatus,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (guild.description ?? '').trim().isNotEmpty
                                ? guild.description!
                                : 'Tông môn này hiện chưa có mô tả.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFFE9D7AE).withOpacity(0.70),
                              fontSize: 12.5,
                              height: 1.42,
                            ),
                          ),
                          const SizedBox(height: 11),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  guild.slug.isNotEmpty
                                      ? '@${guild.slug}'
                                      : 'Tông môn tu tiên',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.42),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                height: 38,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD27A),
                                      Color(0xFFD4A02F),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4A02F)
                                          .withOpacity(0.20),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      'Xem',
                                      style: TextStyle(
                                        color: Color(0xFF211407),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Color(0xFF211407),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _powerColor(int power) {
    if (power >= 100000) return const Color(0xFFFFD27A);
    if (power >= 50000) return const Color(0xFFB58CFF);
    if (power >= 10000) return const Color(0xFF60A5FA);
    return const Color(0xFFC7962F);
  }
}

class _GuildLogo extends StatelessWidget {
  const _GuildLogo({
    required this.logoUrl,
    required this.accentColor,
  });

  final String? logoUrl;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = logoUrl != null && logoUrl!.trim().isNotEmpty;

    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.95),
            accentColor.withOpacity(0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21170F),
          borderRadius: BorderRadius.circular(19),
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
        size: 38,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80).withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF4ADE80).withOpacity(0.42),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF86EFAC),
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF151D31),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFE9D7AE),
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}