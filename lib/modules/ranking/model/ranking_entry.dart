class RankingEntry {
  final int rank;
  final String name;
  final int score;
  final String? avatarUrl;
  final String? subtitle;

  RankingEntry({
    required this.rank,
    required this.name,
    required this.score,
    this.avatarUrl,
    this.subtitle,
  });

  factory RankingEntry.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic value) => int.tryParse('$value') ?? 0;

    return RankingEntry(
      rank: parseInt(map['rank'] ?? map['position'] ?? map['top']),
      name: (map['displayName'] ??
          map['userName'] ??
          map['username'] ??
          map['name'] ??
          'Người chơi')
          .toString(),
      score: parseInt(
        map['score'] ??
            map['value'] ??
            map['points'] ??
            map['power'] ??
            map['exp'],
      ),
      avatarUrl: map['avatarUrl']?.toString(),
      subtitle: (map['guildName'] ??
          map['guild_name'] ??
          map['title'] ??
          map['role'])
          ?.toString(),
    );
  }
}