class AfkClaimResult {
  final int claimedExp;
  final int claimedGold;

  AfkClaimResult({
    required this.claimedExp,
    required this.claimedGold,
  });

  factory AfkClaimResult.fromMap(Map<String, dynamic> map) {
    return AfkClaimResult(
      claimedExp: (map['claimedExp'] as num?)?.toInt() ?? 0,
      claimedGold: (map['claimedGold'] as num?)?.toInt() ?? 0,
    );
  }
}