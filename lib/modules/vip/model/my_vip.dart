class MyVip {
  final int? userVipId;
  final int vipLevelId;
  final int vipLevelNumber;
  final String vipLevelName;
  final int cumulativeTopupAmount;
  final String? startedAt;
  final String? expiresAt;
  final bool isActive;

  MyVip({
    required this.userVipId,
    required this.vipLevelId,
    required this.vipLevelNumber,
    required this.vipLevelName,
    required this.cumulativeTopupAmount,
    this.startedAt,
    this.expiresAt,
    required this.isActive,
  });

  factory MyVip.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();

      final text = value.toString().replaceAll(',', '').trim();
      return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
    }

    int? toNullableInt(dynamic value) {
      if (value == null) return null;
      final parsed = toInt(value);
      return parsed == 0 && value.toString() != '0' ? null : parsed;
    }

    bool toBool(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is int) return value == 1;

      final text = value.toString().toLowerCase().trim();
      return text == '1' || text == 'true' || text == 'active';
    }

    return MyVip(
      userVipId: toNullableInt(map['user_vip_id'] ?? map['id']),
      vipLevelId: toInt(
        map['vip_level_id'] ??
            map['level_id'] ??
            map['current_vip_level_id'] ??
            map['vipLevelId'],
      ),
      vipLevelNumber: toInt(
        map['vip_level_number'] ??
            map['level_number'] ??
            map['vip_level'] ??
            map['level'] ??
            map['vipLevelNumber'],
      ),
      vipLevelName: (
          map['vip_level_name'] ??
              map['level_name'] ??
              map['name'] ??
              map['vip_name'] ??
              'Thường'
      ).toString(),
      cumulativeTopupAmount: toInt(
        map['cumulative_topup_amount'] ??
            map['required_topup_amount'] ??
            map['total_topup_amount'] ??
            map['cumulativeTopupAmount'] ??
            map['totalTopupAmount'],
      ),
      startedAt: (
          map['started_at'] ??
              map['vip_started_at'] ??
              map['vipStartedAt']
      )?.toString(),
      expiresAt: (
          map['expires_at'] ??
              map['vip_expired_at'] ??
              map['vipExpiredAt']
      )?.toString(),
      isActive: toBool(map['is_active'] ?? map['active']),
    );
  }

  factory MyVip.empty() {
    return MyVip(
      userVipId: null,
      vipLevelId: 0,
      vipLevelNumber: 0,
      vipLevelName: 'Thường',
      cumulativeTopupAmount: 0,
      startedAt: null,
      expiresAt: null,
      isActive: true,
    );
  }
}