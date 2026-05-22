class AfkSession {
  final int id;
  final String sessionStatus;
  final String claimStatus;

  final DateTime? startedAt;
  final DateTime? endedAt;

  final int durationSeconds;

  final int baseExpEarned;
  final int bonusExpEarned;
  final int totalExpEarned;

  final double baseGoldEarned;
  final double bonusGoldEarned;
  final double totalGoldEarned;

  const AfkSession({
    required this.id,
    required this.sessionStatus,
    required this.claimStatus,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.baseExpEarned,
    required this.bonusExpEarned,
    required this.totalExpEarned,
    required this.baseGoldEarned,
    required this.bonusGoldEarned,
    required this.totalGoldEarned,
  });

  factory AfkSession.fromMap(Map<String, dynamic> map) {
    return AfkSession(
      id: _toInt(_pick(map, ['id'])),
      sessionStatus: _pick(map, ['session_status', 'sessionStatus'])
          ?.toString() ??
          'running',
      claimStatus: _pick(map, ['claim_status', 'claimStatus'])
          ?.toString() ??
          'pending',
      startedAt: _toDateTime(_pick(map, ['started_at', 'startedAt'])),
      endedAt: _toDateTime(_pick(map, ['ended_at', 'endedAt'])),
      durationSeconds: _toInt(_pick(map, ['duration_seconds', 'durationSeconds'])),
      baseExpEarned: _toInt(_pick(map, ['base_exp_earned', 'baseExpEarned'])),
      bonusExpEarned: _toInt(_pick(map, ['bonus_exp_earned', 'bonusExpEarned'])),
      totalExpEarned: _toInt(_pick(map, ['total_exp_earned', 'totalExpEarned'])),
      baseGoldEarned: _toDouble(_pick(map, ['base_gold_earned', 'baseGoldEarned'])),
      bonusGoldEarned:
      _toDouble(_pick(map, ['bonus_gold_earned', 'bonusGoldEarned'])),
      totalGoldEarned:
      _toDouble(_pick(map, ['total_gold_earned', 'totalGoldEarned'])),
    );
  }

  bool get isRunning => sessionStatus == 'running';

  bool get isFinished => sessionStatus == 'finished';

  bool get canClaim => isFinished && claimStatus == 'pending';

  static dynamic _pick(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) return map[key];
    }

    return null;
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

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') return null;

    return DateTime.tryParse(text)?.toLocal();
  }
}