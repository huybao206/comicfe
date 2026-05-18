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
      id: _toInt(map['id']),
      sessionStatus: (map['session_status'] ?? 'running').toString(),
      claimStatus: (map['claim_status'] ?? 'pending').toString(),
      startedAt: _toDateTime(map['started_at']),
      endedAt: _toDateTime(map['ended_at']),
      durationSeconds: _toInt(map['duration_seconds']),
      baseExpEarned: _toInt(map['base_exp_earned']),
      bonusExpEarned: _toInt(map['bonus_exp_earned']),
      totalExpEarned: _toInt(map['total_exp_earned']),
      baseGoldEarned: _toDouble(map['base_gold_earned']),
      bonusGoldEarned: _toDouble(map['bonus_gold_earned']),
      totalGoldEarned: _toDouble(map['total_gold_earned']),
    );
  }

  bool get isRunning => sessionStatus == 'running';

  bool get isFinished => sessionStatus == 'finished';

  bool get canClaim => isFinished && claimStatus == 'pending';

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

    return DateTime.tryParse(text);
  }
}