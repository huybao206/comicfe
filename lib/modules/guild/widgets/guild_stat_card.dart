import 'package:flutter/material.dart';

class GuildStatCard extends StatelessWidget {
  const GuildStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.accentColor = const Color(0xFFFFD27A),
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF10182B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: accentColor,
              size: 21,
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.46),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFE9B0),
                fontWeight: FontWeight.w900,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}