class CultivationLevel {
  final int id;
  final int levelNumber;
  final int realmId;
  final String realmName;
  final int stageNumber;
  final String stageBand;
  final String stageName;
  final int expRequired;
  final int cumulativeExp;
  final int powerPoints;
  final double afkMultiplier;
  final double afkExpPerMin;
  final double afkGoldPerMin;
  final bool isBreakthroughLevel;
  final String? breakthroughToRealmName;

  const CultivationLevel({
    required this.id,
    required this.levelNumber,
    required this.realmId,
    required this.realmName,
    required this.stageNumber,
    required this.stageBand,
    required this.stageName,
    required this.expRequired,
    required this.cumulativeExp,
    required this.powerPoints,
    required this.afkMultiplier,
    required this.afkExpPerMin,
    required this.afkGoldPerMin,
    required this.isBreakthroughLevel,
    required this.breakthroughToRealmName,
  });

  factory CultivationLevel.fromJson(Map<String, dynamic> json) {
    return CultivationLevel(
      id: _toInt(json['id']),
      levelNumber: _toInt(json['level_number'] ?? json['levelNumber']),
      realmId: _toInt(json['realm_id'] ?? json['realmId']),
      realmName: (json['realm_name'] ?? json['realmName'] ?? '').toString(),
      stageNumber: _toInt(json['stage_number'] ?? json['stageNumber']),
      stageBand: (json['stage_band'] ?? json['stageBand'] ?? '').toString(),
      stageName: (json['stage_name'] ?? json['stageName'] ?? '').toString(),
      expRequired: _toInt(json['exp_required'] ?? json['expRequired']),
      cumulativeExp: _toInt(json['cumulative_exp_to_reach_level'] ?? json['cumulativeExp']),
      powerPoints: _toInt(json['power_points'] ?? json['powerPoints']),
      afkMultiplier: _toDouble(json['afk_multiplier'] ?? json['afkMultiplier'], 1),
      afkExpPerMin: _toDouble(json['afk_exp_per_min'] ?? json['afkExpPerMin'], 0),
      afkGoldPerMin: _toDouble(json['afk_gold_per_min'] ?? json['afkGoldPerMin'], 0),
      isBreakthroughLevel: _toBool(json['is_breakthrough_level'] ?? json['isBreakthroughLevel']),
      breakthroughToRealmName: json['breakthrough_to_realm_name']?.toString(),
    );
  }
}

class CultivationRule {
  final int breakthroughLevel;
  final String fromRealmName;
  final String toRealmName;
  final String requiredItemName;
  final int requiredItemQuantity;
  final double baseSuccessRatePercent;
  final double failBonusPerFail;
  final int failReturnLevel;
  final String insuranceItemName;
  final int insuranceItemQuantity;
  final double insuranceExpLossPercent;
  final int failCount;
  final double currentSuccessRatePercent;

  const CultivationRule({
    required this.breakthroughLevel,
    required this.fromRealmName,
    required this.toRealmName,
    required this.requiredItemName,
    required this.requiredItemQuantity,
    required this.baseSuccessRatePercent,
    required this.failBonusPerFail,
    required this.failReturnLevel,
    required this.insuranceItemName,
    required this.insuranceItemQuantity,
    required this.insuranceExpLossPercent,
    required this.failCount,
    required this.currentSuccessRatePercent,
  });

  factory CultivationRule.fromJson(Map<String, dynamic> json) {
    return CultivationRule(
      breakthroughLevel: _toInt(json['breakthrough_level'] ?? json['breakthroughLevel']),
      fromRealmName: (json['from_realm_name'] ?? json['fromRealmName'] ?? '').toString(),
      toRealmName: (json['to_realm_name'] ?? json['toRealmName'] ?? '').toString(),
      requiredItemName: (json['required_item_name'] ?? json['requiredItemName'] ?? '').toString(),
      requiredItemQuantity: _toInt(json['required_item_quantity'] ?? json['requiredItemQuantity']),
      baseSuccessRatePercent: _toDouble(json['success_rate_percent'] ?? json['baseSuccessRatePercent'], 0),
      failBonusPerFail: _toDouble(json['fail_bonus_per_fail'] ?? json['failBonusPerFail'], 0.05),
      failReturnLevel: _toInt(json['fail_return_level'] ?? json['failReturnLevel']),
      insuranceItemName: (json['insurance_item_name'] ?? json['insuranceItemName'] ?? '').toString(),
      insuranceItemQuantity: _toInt(json['insurance_item_quantity'] ?? json['insuranceItemQuantity']),
      insuranceExpLossPercent: _toDouble(json['insurance_exp_loss_percent'] ?? json['insuranceExpLossPercent'], 0.5),
      failCount: _toInt(json['fail_count'] ?? json['failCount']),
      currentSuccessRatePercent: _toDouble(json['current_success_rate_percent'] ?? json['currentSuccessRatePercent'] ?? json['success_rate_percent'], 0),
    );
  }
}

class CultivationStateData {
  final Map<String, dynamic> cultivation;
  final CultivationRule? currentRule;
  final List<CultivationLevel> levels;

  const CultivationStateData({
    required this.cultivation,
    required this.currentRule,
    required this.levels,
  });

  factory CultivationStateData.fromJson(Map<String, dynamic> json) {
    final rawLevels = json['levels'];
    final rawRule = json['currentRule'] ?? json['current_rule'];
    return CultivationStateData(
      cultivation: Map<String, dynamic>.from(json['cultivation'] ?? {}),
      currentRule: rawRule is Map ? CultivationRule.fromJson(Map<String, dynamic>.from(rawRule)) : null,
      levels: rawLevels is List
          ? rawLevels.whereType<Map>().map((e) => CultivationLevel.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
    );
  }

  int get levelNumber => _toInt(cultivation['level_number'] ?? cultivation['levelNumber']);
  String get realmName => (cultivation['realm_name'] ?? cultivation['realmName'] ?? '').toString();
  int get stageNumber => _toInt(cultivation['stage_number'] ?? cultivation['stageNumber']);
  String get stageName => (cultivation['stage_name'] ?? cultivation['stageName'] ?? '').toString();
  int get currentExp => _toInt(cultivation['current_exp'] ?? cultivation['currentExp']);
  int get expRequired => _toInt(cultivation['exp_required'] ?? cultivation['expRequired']);
  int get combatPower => _toInt(cultivation['combat_power'] ?? cultivation['combatPower']);
  double get afkMultiplier => _toDouble(cultivation['afk_multiplier'] ?? cultivation['afkMultiplier'], 1);
  bool get isBreakthroughLevel => _toBool(cultivation['is_breakthrough_level'] ?? cultivation['isBreakthroughLevel']);
  double get progressRatio => expRequired <= 0 ? 0 : (currentExp / expRequired).clamp(0, 1).toDouble();
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase().trim() ?? '';
  return text == 'true' || text == '1' || text == 'yes';
}
