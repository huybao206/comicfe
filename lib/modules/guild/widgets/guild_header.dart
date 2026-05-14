import 'package:flutter/material.dart';

class GuildHeader extends StatelessWidget {
  const GuildHeader({
    super.key,
    required this.totalGuilds,
    required this.strongGuilds,
    required this.leaderGuilds,
  });

  final int totalGuilds;
  final int strongGuilds;
  final int leaderGuilds;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      height: 188,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF7A5A26)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A02F).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  Color(0xFF574117),
                  Color(0xFF23170C),
                  Color(0xFF0E101A),
                ],
                stops: [0, 0.48, 1],
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A02F).withOpacity(0.11),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -42,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6574FF).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            right: 18,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD27A),
                        Color(0xFFD4A02F),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A02F).withOpacity(0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Color(0xFF211407),
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tông Môn Bảng',
                        style: TextStyle(
                          color: Color(0xFFFFE9B0),
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Chiêu mộ đồng đạo, xây dựng bang phái và vươn lên đỉnh tu tiên.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFD7C39A),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: _StatPill(
                    icon: Icons.shield_outlined,
                    label: 'Guild',
                    value: '$totalGuilds',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatPill(
                    icon: Icons.bolt_outlined,
                    label: 'Power',
                    value: '$strongGuilds',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatPill(
                    icon: Icons.person_outline_rounded,
                    label: 'Leader',
                    value: '$leaderGuilds',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD27A),
            size: 18,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}