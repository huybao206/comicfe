import 'package:flutter/material.dart';

class AfkEmptyView extends StatelessWidget {
  const AfkEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: Color(0xFFD0B06A),
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Hiện chưa có cấu hình AFK nào.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE6D4AC),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}