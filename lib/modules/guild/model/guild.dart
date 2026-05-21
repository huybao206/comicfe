import '../../../core/config/app_env.dart';

class Guild {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? announcement;
  final String? logoUrl;
  final String? joinRequirementText;
  final int? joinMinLevel;
  final int? joinMinPower;
  final int? level;
  final int? guildPower;
  final int? contributionPoints;
  final int? currentExp;
  final int? nextLevelExp;
  final int? memberLimit;
  final int? memberCount;
  final int? chatRoomId;
  final String? guildStatus;
  final String? leaderName;
  final String? leaderAvatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Guild({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.announcement,
    this.logoUrl,
    this.joinRequirementText,
    this.joinMinLevel,
    this.joinMinPower,
    this.level,
    this.guildPower,
    this.contributionPoints,
    this.currentExp,
    this.nextLevelExp,
    this.memberLimit,
    this.memberCount,
    this.chatRoomId,
    this.guildStatus,
    this.leaderName,
    this.leaderAvatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Guild.fromMap(Map<String, dynamic> map) {
    final guildMap = map['guild'] is Map
        ? Map<String, dynamic>.from(map['guild'] as Map)
        : map;
    final leaderMap = map['leader'] is Map
        ? Map<String, dynamic>.from(map['leader'] as Map)
        : <String, dynamic>{};

    return Guild(
      id: _toInt(guildMap['id'] ?? guildMap['guild_id'] ?? guildMap['guildId']),
      name: (guildMap['name'] ??
          guildMap['guild_name'] ??
          guildMap['guildName'] ??
          'Tông môn')
          .toString(),
      slug: (guildMap['slug'] ?? guildMap['guild_slug'] ?? guildMap['guildSlug'] ?? '')
          .toString(),
      description: guildMap['description']?.toString(),
      announcement: (guildMap['announcement'] ?? map['announcement'])?.toString(),
      logoUrl: _buildFullImageUrl(
        (guildMap['logo_url'] ??
            guildMap['logoUrl'] ??
            guildMap['image_url'] ??
            guildMap['imageUrl'])
            ?.toString(),
      ),
      joinRequirementText: (guildMap['join_requirement_text'] ??
          guildMap['joinRequirementText'] ??
          guildMap['requirement_text'] ??
          guildMap['requirementText'])
          ?.toString(),
      joinMinLevel: _toNullableInt(
        guildMap['join_min_level'] ?? guildMap['joinMinLevel'] ?? guildMap['min_level'],
      ),
      joinMinPower: _toNullableInt(
        guildMap['join_min_power'] ?? guildMap['joinMinPower'] ?? guildMap['min_power'],
      ),
      level: _toNullableInt(guildMap['level'] ?? guildMap['guild_level']),
      guildPower: _toNullableInt(
        guildMap['guild_power'] ?? guildMap['guildPower'] ?? guildMap['power'],
      ),
      contributionPoints: _toNullableInt(
        guildMap['contribution_points'] ??
            guildMap['contributionPoints'] ??
            guildMap['contribution'],
      ),
      currentExp: _toNullableInt(
        guildMap['current_exp'] ??
            guildMap['currentExp'] ??
            guildMap['guild_current_exp'] ??
            guildMap['guildCurrentExp'],
      ),
      nextLevelExp: _toNullableInt(
        guildMap['next_level_exp'] ??
            guildMap['nextLevelExp'] ??
            guildMap['exp_to_next_level'] ??
            guildMap['expToNextLevel'],
      ),
      memberLimit: _toNullableInt(guildMap['member_limit'] ?? guildMap['memberLimit']),
      memberCount: _toNullableInt(
        map['member_count'] ??
            map['memberCount'] ??
            guildMap['member_count'] ??
            guildMap['memberCount'],
      ),
      chatRoomId: _toNullableInt(
        map['chat_room_id'] ??
            map['chatRoomId'] ??
            guildMap['chat_room_id'] ??
            guildMap['chatRoomId'],
      ),
      guildStatus: (guildMap['guild_status'] ??
          guildMap['guildStatus'] ??
          guildMap['status'])
          ?.toString(),
      leaderName: (guildMap['leader_name'] ??
          guildMap['leaderName'] ??
          leaderMap['display_name'] ??
          leaderMap['displayName'] ??
          guildMap['owner_name'] ??
          guildMap['ownerName'])
          ?.toString(),
      leaderAvatarUrl: _buildFullImageUrl(
        (guildMap['leader_avatar_url'] ??
            guildMap['leaderAvatarUrl'] ??
            leaderMap['avatar_url'] ??
            leaderMap['avatarUrl'])
            ?.toString(),
      ),
      createdAt: _toNullableDateTime(guildMap['created_at'] ?? guildMap['createdAt']),
      updatedAt: _toNullableDateTime(guildMap['updated_at'] ?? guildMap['updatedAt']),
    );
  }

  bool get hasLogo => logoUrl != null && logoUrl!.trim().isNotEmpty;

  bool get hasLeader => leaderName != null && leaderName!.trim().isNotEmpty;

  bool get hasStatus => guildStatus != null && guildStatus!.trim().isNotEmpty;

  String get displayJoinRequirement {
    final text = joinRequirementText?.trim() ?? '';
    if (text.isNotEmpty) return text;

    final level = joinMinLevel ?? 1;
    final power = joinMinPower ?? 0;
    final parts = <String>[];
    if (level > 1) parts.add('Cấp tối thiểu $level');
    if (power > 0) parts.add('Chiến lực tối thiểu $power');
    if (parts.isEmpty) return 'Cần được bang chủ duyệt để gia nhập';
    return parts.join(' • ');
  }

  String get joinRequirementSummary {
    final level = joinMinLevel ?? 1;
    final power = joinMinPower ?? 0;
    if (level <= 1 && power <= 0) return 'Không giới hạn cấp/chiến lực';
    if (power <= 0) return 'Cấp $level trở lên';
    if (level <= 1) return 'Chiến lực $power trở lên';
    return 'Cấp $level • Chiến lực $power';
  }

  String get displayStatus {
    final value = guildStatus?.trim().toLowerCase() ?? '';
    if (value == 'active') return 'Đang hoạt động';
    if (value == 'locked') return 'Đã khóa';
    if (value == 'disbanded') return 'Đã giải tán';
    if (value.isEmpty) return 'Đang hoạt động';
    return guildStatus!;
  }

  String get memberText {
    final count = memberCount ?? 0;
    final limit = memberLimit ?? 0;
    if (limit > 0) return '$count/$limit';
    return '$count';
  }

  int get safeCurrentExp => currentExp ?? 0;

  int get safeNextLevelExp {
    final value = nextLevelExp ?? 0;
    if (value > 0) return value;
    final safeLevel = level ?? 1;
    return safeLevel <= 0 ? 1000 : safeLevel * 1000;
  }

  double get expProgress {
    final total = safeNextLevelExp;
    if (total <= 0) return 0;
    final ratio = safeCurrentExp / total;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  String get expText => '$safeCurrentExp/$safeNextLevelExp EXP';

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

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return null;

    return DateTime.tryParse(text);
  }

  static String? _buildFullImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final value = raw.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final normalized = value.replaceAll('\\', '/');
    final mediaBaseUrl = AppEnv.baseUrl.replaceFirst('/api', '');

    if (normalized.startsWith('/')) {
      return '$mediaBaseUrl$normalized';
    }

    return '$mediaBaseUrl/$normalized';
  }
}
