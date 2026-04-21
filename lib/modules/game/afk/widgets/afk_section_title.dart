import 'package:flutter/material.dart';

class AfkSectionTitle extends StatelessWidget {
  const AfkSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFF3DEAD),
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}