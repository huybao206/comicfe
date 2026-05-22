import 'package:flutter/material.dart';

import '../model/guild_join_request.dart';

class GuildJoinRequestTile extends StatelessWidget {
  const GuildJoinRequestTile({
    super.key,
    required this.request,
    this.isSubmitting = false,
    this.onApprove,
    this.onReject,
  });

  final GuildJoinRequest request;
  final bool isSubmitting;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.group_add_outlined,
                color: Color(0xFFE0B85C),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style: const TextStyle(
                        color: Color(0xFFE8D7B3),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if ((request.message ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        request.message!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.58),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A02F).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Chờ duyệt',
                  style: TextStyle(
                    color: Color(0xFFFFD27A),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmitting ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8A8A),
                    side: const BorderSide(color: Color(0xFF8A3A3A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A02F),
                    foregroundColor: const Color(0xFF211407),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Duyệt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
