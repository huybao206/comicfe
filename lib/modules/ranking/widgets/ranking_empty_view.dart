import 'package:flutter/material.dart';

class RankingEmptyView extends StatelessWidget {
  const RankingEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            color: Color(0xFFD0B06A),
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Hiện chưa có dữ liệu bảng xếp hạng.',
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