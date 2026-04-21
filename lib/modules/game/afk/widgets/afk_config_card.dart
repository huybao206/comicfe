import 'package:flutter/material.dart';

import '../model/afk_config.dart';
import 'afk_info_chip.dart';

class AfkConfigCard extends StatelessWidget {
  const AfkConfigCard({
    super.key,
    required this.config,
  });

  final AfkConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF735624)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF7B5C28)),
              color: const Color(0xFF21170F),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFFE0B85C),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.configKey,
                  style: const TextStyle(
                    color: Color(0xFFF6E7BE),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (config.description ?? '').isNotEmpty
                      ? config.description!
                      : 'Không có mô tả',
                  style: const TextStyle(
                    color: Color(0xFFD5C6A2),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AfkInfoChip(
                      icon: Icons.data_object_rounded,
                      text: 'Type: ${config.valueType ?? '-'}',
                    ),
                    AfkInfoChip(
                      icon: Icons.auto_awesome_rounded,
                      text: 'Value: ${_valueText(config.parsedValue)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _valueText(dynamic value) {
    if (value == null) return 'null';
    return value.toString();
  }
}