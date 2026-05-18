import 'package:flutter/material.dart';

class RankingEmptyView extends StatelessWidget {
  const RankingEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 72),
      padding: const EdgeInsets.all(22),
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
                color: const Color(0xFFD4A02F).withOpacity(0.40),
              ),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Color(0xFFFFD27A),
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Chưa có dữ liệu bảng xếp hạng',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Khi người chơi phát sinh điểm, bảng xếp hạng sẽ hiển thị tại đây.',
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