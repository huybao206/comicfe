class GuildMember {
  final int id;
  final int userId;
  final String name;
  final String? role;
  final String? roleCode;
  final int? contributionPoints;
  final String? joinedAt;

  GuildMember({
    required this.id,
    required this.userId,
    required this.name,
    this.role,
    this.roleCode,
    this.contributionPoints,
    this.joinedAt,
  });

  factory GuildMember.fromMap(Map<String, dynamic> map) {
    final userName = map['display_name'] ??
        map['displayName'] ??
        map['username'] ??
        map['name'] ??
        map['member_name'] ??
        map['memberName'] ??
        'Thành viên';

    final rawRoleCode = (map['display_role_code'] ??
        map['displayRoleCode'] ??
        map['role_code'] ??
        map['roleCode'] ??
        '')
        .toString()
        .trim()
        .toLowerCase();

    final rawRole = (map['role'] ??
        map['role_name'] ??
        map['roleName'] ??
        map['guild_role_name'] ??
        map['guildRoleName'] ??
        '')
        .toString()
        .trim();

    return GuildMember(
      id: _toInt(map['id'] ?? map['guild_member_id'] ?? map['guildMemberId']),
      userId: _toInt(map['user_id'] ?? map['userId']),
      name: userName.toString(),
      role: _normalizeRole(rawRoleCode, rawRole),
      roleCode: rawRoleCode.isEmpty ? null : rawRoleCode,
      contributionPoints: _toNullableInt(
        map['contribution_points'] ?? map['contributionPoints'] ?? map['points'],
      ),
      joinedAt: map['joined_at']?.toString() ?? map['joinedAt']?.toString(),
    );
  }

  bool get isLeader {
    final code = roleCode?.toLowerCase().trim() ?? '';
    final label = role?.toLowerCase().trim() ?? '';
    return code == 'leader' || code == 'owner' || label.contains('bang chủ');
  }

  static String _normalizeRole(String code, String role) {
    final lowerCode = code.toLowerCase().trim();
    final text = role.trim();

    if (lowerCode == 'leader' || lowerCode == 'owner') return 'Bang chủ';
    if (lowerCode == 'vice_leader') return 'Phó bang';
    if (lowerCode == 'elder') return 'Trưởng lão';
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;

    return 'Thành viên';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return null;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }
}
