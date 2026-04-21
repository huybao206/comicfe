import 'package:flutter/material.dart';

class RankingHeader extends StatelessWidget {
  const RankingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B1E12),
            Color(0xFF17110C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7A5A26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFC7962F).withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF9C742C)),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFE8C36D),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thiên Kiêu Bảng',
                  style: TextStyle(
                    color: Color(0xFFF6E7BE),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Theo dõi thứ hạng cao thủ theo từng loại chỉ số trong thế giới tu luyện.',
                  style: TextStyle(
                    color: Color(0xFFD7C39A),
                    height: 1.45,
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