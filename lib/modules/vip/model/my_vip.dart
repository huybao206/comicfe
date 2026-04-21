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
    int toInt(dynamic value) => int.tryParse('$value') ?? 0;
    int? toNullableInt(dynamic value) =>
        value == null ? null : int.tryParse('$value');

    return MyVip(
      userVipId: toNullableInt(map['user_vip_id'] ?? map['id']),
      vipLevelId: toInt(map['vip_level_id'] ?? map['level_id']),
      vipLevelNumber: toInt(map['vip_level_number'] ?? map['level_number']),
      vipLevelName: (map['vip_level_name'] ?? map['level_name'] ?? 'Thường')
          .toString(),
      cumulativeTopupAmount: toInt(
        map['cumulative_topup_amount'] ?? map['cumulativeTopupAmount'],
      ),
      startedAt: map['started_at']?.toString(),
      expiresAt: map['expires_at']?.toString(),
      isActive: '${map['is_active']}' == '1' || map['is_active'] == true,
    );
  }
}