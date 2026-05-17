class VipLevel {
  final int id;
  final int vipLevelNumber;
  final String vipLevelName;
  final int requiredTopupAmount;
  final String badgeName;
  final String badgeColor;
  final String description;
  final bool isActive;

  VipLevel({
    required this.id,
    required this.vipLevelNumber,
    required this.vipLevelName,
    required this.requiredTopupAmount,
    required this.badgeName,
    required this.badgeColor,
    required this.description,
    required this.isActive,
  });

  factory VipLevel.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();

      final text = value.toString().replaceAll(',', '').trim();
      return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
    }

    bool toBool(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is int) return value == 1;

      final text = value.toString().toLowerCase().trim();
      return text == '1' || text == 'true' || text == 'active';
    }

    return VipLevel(
      id: toInt(map['id'] ?? map['vip_level_id'] ?? map['level_id']),
      vipLevelNumber: toInt(
        map['vip_level_number'] ??
            map['level_number'] ??
            map['vip_level'] ??
            map['level'],
      ),
      vipLevelName: (
          map['vip_level_name'] ??
              map['level_name'] ??
              map['name'] ??
              'VIP'
      ).toString(),
      requiredTopupAmount: toInt(
        map['required_topup_amount'] ??
            map['required_cumulative_topup'] ??
            map['requiredTopupAmount'],
      ),
      badgeName: (map['badge_name'] ?? '').toString(),
      badgeColor: (map['badge_color'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      isActive: toBool(map['is_active'] ?? map['active']),
    );
  }

  factory VipLevel.fromJson(Map<String, dynamic> json) {
    return VipLevel.fromMap(json);
  }

  // ===== Compatibility getters =====

  int get level => vipLevelNumber;

  int get levelNumber => vipLevelNumber;

  String get levelName => vipLevelName;

  String get name => vipLevelName;

  int get requiredCumulativeTopup => requiredTopupAmount;

  int get requiredTopup => requiredTopupAmount;

  bool get active => isActive;
}