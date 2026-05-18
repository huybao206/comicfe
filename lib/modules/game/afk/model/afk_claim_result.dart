class AfkClaimResult {
  final int claimedExp;
  final double claimedGold;

  const AfkClaimResult({
    required this.claimedExp,
    required this.claimedGold,
  });

  factory AfkClaimResult.fromMap(Map<String, dynamic> map) {
    return AfkClaimResult(
      claimedExp: _toInt(map['claimedExp'] ?? map['claimed_exp']),
      claimedGold: _toDouble(map['claimedGold'] ?? map['claimed_gold']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}