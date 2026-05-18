import 'package:flutter/material.dart';

import '../model/afk_config.dart';

class AfkConfigCard extends StatelessWidget {
  const AfkConfigCard({
    super.key,
    required this.config,
  });

  final AfkConfig config;

  @override
  Widget build(BuildContext context) {
    final meta = _meta(config.configKey);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.color.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: meta.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: meta.color.withOpacity(0.36)),
            ),
            child: Icon(
              meta.icon,
              color: meta.color,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.label,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.description?.trim().isNotEmpty == true
                      ? config.description!
                      : config.configKey,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _valueText(config),
                style: const TextStyle(
                  color: Color(0xFFFFE9B0),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                config.valueType ?? '-',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.40),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _valueText(AfkConfig config) {
    final value = config.parsedValue ?? config.configValue ?? '-';

    if (value is bool) {
      return value ? 'Bật' : 'Tắt';
    }

    return value.toString();
  }

  _ConfigMeta _meta(String key) {
    switch (key) {
      case 'afk_enabled':
        return const _ConfigMeta(
          label: 'Trạng thái AFK',
          icon: Icons.power_settings_new_rounded,
          color: Color(0xFF4ADE80),
        );
      case 'afk_exp_per_minute':
        return const _ConfigMeta(
          label: 'EXP mỗi phút',
          icon: Icons.auto_awesome_rounded,
          color: Color(0xFF8FB0FF),
        );
      case 'afk_gold_per_minute':
        return const _ConfigMeta(
          label: 'Vàng mỗi phút',
          icon: Icons.monetization_on_outlined,
          color: Color(0xFFFFD27A),
        );
      case 'afk_vip_bonus_percent':
        return const _ConfigMeta(
          label: 'Bonus VIP',
          icon: Icons.workspace_premium_outlined,
          color: Color(0xFFFF7AA8),
        );
      case 'afk_min_minutes_to_claim':
        return const _ConfigMeta(
          label: 'Phút tối thiểu nhận thưởng',
          icon: Icons.timer_outlined,
          color: Color(0xFF4ADE80),
        );
      case 'afk_max_minutes_per_session':
        return const _ConfigMeta(
          label: 'Giới hạn một phiên',
          icon: Icons.hourglass_bottom_rounded,
          color: Color(0xFFB58CFF),
        );
      case 'afk_daily_max_minutes':
        return const _ConfigMeta(
          label: 'Giới hạn mỗi ngày',
          icon: Icons.calendar_month_outlined,
          color: Color(0xFF60A5FA),
        );
      default:
        return const _ConfigMeta(
          label: 'Cấu hình AFK',
          icon: Icons.tune_rounded,
          color: Color(0xFFC7962F),
        );
    }
  }
}

class _ConfigMeta {
  final String label;
  final IconData icon;
  final Color color;

  const _ConfigMeta({
    required this.label,
    required this.icon,
    required this.color,
  });
}