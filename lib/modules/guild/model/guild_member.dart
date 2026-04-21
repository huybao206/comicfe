class GuildMember {
  final int id;
  final String name;
  final String? role;
  final int? contributionPoints;
  final String? joinedAt;

  GuildMember({
    required this.id,
    required this.name,
    this.role,
    this.contributionPoints,
    this.joinedAt,
  });

  factory GuildMember.fromMap(Map<String, dynamic> map) {
    final userName = map['display_name'] ??
        map['username'] ??
        map['name'] ??
        map['member_name'] ??
        'Thành viên';

    return GuildMember(
      id: int.tryParse('${map['id'] ?? map['user_id'] ?? 0}') ?? 0,
      name: userName.toString(),
      role: map['role']?.toString(),
      contributionPoints:
      int.tryParse('${map['contribution_points'] ?? map['points'] ?? ''}'),
      joinedAt: map['joined_at']?.toString(),
    );
  }
}