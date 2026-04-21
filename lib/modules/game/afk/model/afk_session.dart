class AfkSession {
  final int id;
  final String sessionStatus;
  final int durationSeconds;
  final int baseExpEarned;
  final int bonusExpEarned;
  final int totalExpEarned;

  AfkSession({
    required this.id,
    required this.sessionStatus,
    required this.durationSeconds,
    required this.baseExpEarned,
    required this.bonusExpEarned,
    required this.totalExpEarned,
  });

  factory AfkSession.fromMap(Map<String, dynamic> map) {
    return AfkSession(
      id: (map['id'] as num?)?.toInt() ?? 0,
      sessionStatus: (map['session_status'] ?? 'running').toString(),
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      baseExpEarned: (map['base_exp_earned'] as num?)?.toInt() ?? 0,
      bonusExpEarned: (map['bonus_exp_earned'] as num?)?.toInt() ?? 0,
      totalExpEarned: (map['total_exp_earned'] as num?)?.toInt() ?? 0,
    );
  }
}