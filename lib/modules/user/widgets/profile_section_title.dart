import 'package:flutter/material.dart';

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.action,
  });

  final String title;
  final IconData icon;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF6574FF).withOpacity(0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3E4EA8)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFBFD0FF),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.46),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}