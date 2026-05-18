import 'package:flutter/material.dart';

class AfkEmptyView extends StatelessWidget {
  const AfkEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A02F).withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4A02F).withOpacity(0.38),
              ),
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              color: Color(0xFFFFD27A),
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Chưa có cấu hình AFK',
            style: TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Hãy thêm cấu hình trong Admin để hệ thống AFK hoạt động đầy đủ.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.54),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}