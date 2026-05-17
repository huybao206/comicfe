import 'package:flutter/material.dart';

class AfkInfoChip extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final Map<String, dynamic>? value;

  // Tương thích với code cũ trong afk_config_card.dart
  final String? text;

  const AfkInfoChip({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.value,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu gọi kiểu cũ: AfkInfoChip(text: '...')
    if (text != null) {
      return _MiniPill(
        text: text!,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF130C08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFC857).withOpacity(0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF23180F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFC857).withOpacity(0.55),
                ),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFFD166),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty)
                  Text(
                    title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFF3D1),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE0CFA5),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
                if (value != null && value!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: value!.entries.map((entry) {
                      return _MiniPill(
                        text: '${entry.key}: ${entry.value}',
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String text;

  const _MiniPill({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF261A10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFC857).withOpacity(0.45)),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: const TextStyle(
          color: Color(0xFFFFD166),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    );
  }
}