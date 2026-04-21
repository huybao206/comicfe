class VipLevel {
  final int id;
  final int levelNumber;
  final String levelName;
  final int requiredCumulativeTopup;
  final bool isActive;

  VipLevel({
    required this.id,
    required this.levelNumber,
    required this.levelName,
    required this.requiredCumulativeTopup,
    required this.isActive,
  });

  factory VipLevel.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic value) => int.tryParse('$value') ?? 0;

    return VipLevel(
      id: toInt(map['id']),
      levelNumber: toInt(map['level_number'] ?? map['levelNumber']),
      levelName: (map['level_name'] ?? map['levelName'] ?? '').toString(),
      requiredCumulativeTopup: toInt(
        map['required_cumulative_topup'] ?? map['requiredCumulativeTopup'],
      ),
      isActive: '${map['is_active']}' == '1' || map['is_active'] == true,
    );
  }
}