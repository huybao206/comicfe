import 'package:flutter/material.dart';

import '../model/guild_donation.dart';

class GuildDonationTile extends StatelessWidget {
  const GuildDonationTile({
    super.key,
    required this.donation,
  });

  final GuildDonation donation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF23180F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5E451D)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volunteer_activism_outlined,
            color: Color(0xFFE0B85C),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              donation.donorName,
              style: const TextStyle(
                color: Color(0xFFE8D7B3),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${donation.contributionPoints} điểm',
            style: const TextStyle(
              color: Color(0xFFF6E7BE),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}