import '../../../core/config/app_env.dart';

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;

  final int level;
  final int exp;
  final int expToNextLevel;

  final int coin;
  final int gold;
  final int spiritStone;

  final int vipLevel;
  final String? vipName;
  final DateTime? vipExpiredAt;

  final int? guildId;
  final String? guildName;
  final String? guildRole;

  final int totalReadChapters;
  final int totalFollowedComics;
  final int totalComments;

  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.level,
    required this.exp,
    required this.expToNextLevel,
    required this.coin,
    required this.gold,
    required this.spiritStone,
    required this.vipLevel,
    required this.vipName,
    required this.vipExpiredAt,
    required this.guildId,
    required this.guildName,
    required this.guildRole,
    required this.totalReadChapters,
    required this.totalFollowedComics,
    required this.totalComments,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final userMap = map['user'] is Map
        ? Map<String, dynamic>.from(map['user'] as Map)
        : map;

    final resourceMap = map['resources'] is Map
        ? Map<String, dynamic>.from(map['resources'] as Map)
        : <String, dynamic>{};

    final cultivationMap = map['cultivation'] is Map
        ? Map<String, dynamic>.from(map['cultivation'] as Map)
        : map['cultivation_summary'] is Map
        ? Map<String, dynamic>.from(map['cultivation_summary'] as Map)
        : <String, dynamic>{};

    final vipMap = map['vip'] is Map
        ? Map<String, dynamic>.from(map['vip'] as Map)
        : map['vip_summary'] is Map
        ? Map<String, dynamic>.from(map['vip_summary'] as Map)
        : <String, dynamic>{};

    final guildMap = map['guild'] is Map
        ? Map<String, dynamic>.from(map['guild'] as Map)
        : map['guild_summary'] is Map
        ? Map<String, dynamic>.from(map['guild_summary'] as Map)
        : <String, dynamic>{};

    final statsMap = map['stats'] is Map
        ? Map<String, dynamic>.from(map['stats'] as Map)
        : <String, dynamic>{};

    return UserProfile(
      id: _toInt(userMap['id'] ?? map['id']),
      username: (userMap['username'] ?? map['username'] ?? '').toString(),
      email: (userMap['email'] ?? map['email'] ?? '').toString(),
      displayName: (userMap['display_name'] ??
          userMap['displayName'] ??
          map['display_name'] ??
          map['displayName'] ??
          userMap['username'] ??
          map['username'] ??
          'Người dùng')
          .toString(),
      avatarUrl: _buildFullImageUrl(
        (userMap['avatar_url'] ??
            userMap['avatarUrl'] ??
            map['avatar_url'] ??
            map['avatarUrl'])
            ?.toString(),
      ),
      bio: (userMap['bio'] ?? map['bio'])?.toString(),

      level: _toInt(
        cultivationMap['level'] ??
            cultivationMap['level_number'] ??
            cultivationMap['levelNumber'] ??
            userMap['level'] ??
            map['level'],
      ),
      exp: _toInt(
        cultivationMap['exp'] ??
            cultivationMap['current_exp'] ??
            userMap['exp'] ??
            map['exp'],
      ),
      expToNextLevel: _toInt(
        cultivationMap['exp_to_next_level'] ??
            cultivationMap['expToNextLevel'] ??
            cultivationMap['exp_required'] ??
            cultivationMap['expRequired'] ??
            map['exp_to_next_level'] ??
            map['expToNextLevel'],
      ),

      coin: _toInt(
        resourceMap['coin'] ??
            resourceMap['coins'] ??
            resourceMap['premium_currency'] ??
            resourceMap['premiumCurrency'] ??
            userMap['coin'] ??
            map['coin'],
      ),
      gold: _toInt(
        resourceMap['gold'] ??
            resourceMap['gold_balance'] ??
            resourceMap['goldBalance'] ??
            userMap['gold'] ??
            map['gold'],
      ),
      spiritStone: _toInt(
        resourceMap['spirit_stone'] ??
            resourceMap['spiritStone'] ??
            resourceMap['spirit_stones'] ??
            resourceMap['spiritStones'] ??
            resourceMap['linh_thach'] ??
            map['spirit_stone'] ??
            map['spiritStone'],
      ),

      vipLevel: _toInt(
        vipMap['level'] ??
            vipMap['vip_level'] ??
            vipMap['vip_level_number'] ??
            vipMap['level_number'] ??
            userMap['vip_level'] ??
            map['vip_level'] ??
            map['vipLevel'],
      ),
      vipName: (vipMap['name'] ??
          vipMap['vip_name'] ??
          vipMap['vip_level_name'] ??
          vipMap['level_name'] ??
          map['vip_name'] ??
          map['vipName'])
          ?.toString(),
      vipExpiredAt: _toNullableDateTime(
        vipMap['expired_at'] ??
            vipMap['expiredAt'] ??
            map['vip_expired_at'] ??
            map['vipExpiredAt'],
      ),

      guildId: _toNullableInt(
        guildMap['id'] ??
            guildMap['guild_id'] ??
            map['guild_id'] ??
            map['guildId'],
      ),
      guildName: (guildMap['name'] ??
          guildMap['guild_name'] ??
          map['guild_name'] ??
          map['guildName'])
          ?.toString(),
      guildRole: (guildMap['role'] ??
          guildMap['member_role'] ??
          guildMap['role_name'] ??
          guildMap['roleName'] ??
          map['guild_role'] ??
          map['guildRole'])
          ?.toString(),

      totalReadChapters: _toInt(
        statsMap['total_read_chapters'] ??
            statsMap['totalReadChapters'] ??
            statsMap['reading_history_count'] ??
            statsMap['readingHistoryCount'] ??
            map['total_read_chapters'] ??
            map['totalReadChapters'],
      ),
      totalFollowedComics: _toInt(
        statsMap['total_followed_comics'] ??
            statsMap['totalFollowedComics'] ??
            statsMap['follow_count'] ??
            statsMap['followCount'] ??
            map['total_followed_comics'] ??
            map['totalFollowedComics'],
      ),
      totalComments: _toInt(
        statsMap['total_comments'] ??
            statsMap['totalComments'] ??
            map['total_comments'] ??
            map['totalComments'],
      ),

      createdAt: _toNullableDateTime(
        userMap['created_at'] ?? userMap['createdAt'] ?? map['created_at'],
      ),
      lastLoginAt: _toNullableDateTime(
        userMap['last_login_at'] ??
            userMap['lastLoginAt'] ??
            map['last_login_at'] ??
            map['lastLoginAt'],
      ),
    );
  }

  UserProfile copyWith({
    int? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? level,
    int? exp,
    int? expToNextLevel,
    int? coin,
    int? gold,
    int? spiritStone,
    int? vipLevel,
    String? vipName,
    DateTime? vipExpiredAt,
    int? guildId,
    String? guildName,
    String? guildRole,
    int? totalReadChapters,
    int? totalFollowedComics,
    int? totalComments,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      expToNextLevel: expToNextLevel ?? this.expToNextLevel,
      coin: coin ?? this.coin,
      gold: gold ?? this.gold,
      spiritStone: spiritStone ?? this.spiritStone,
      vipLevel: vipLevel ?? this.vipLevel,
      vipName: vipName ?? this.vipName,
      vipExpiredAt: vipExpiredAt ?? this.vipExpiredAt,
      guildId: guildId ?? this.guildId,
      guildName: guildName ?? this.guildName,
      guildRole: guildRole ?? this.guildRole,
      totalReadChapters: totalReadChapters ?? this.totalReadChapters,
      totalFollowedComics: totalFollowedComics ?? this.totalFollowedComics,
      totalComments: totalComments ?? this.totalComments,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  double get expProgress {
    if (expToNextLevel <= 0) return 0;
    final value = exp / expToNextLevel;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  bool get hasGuild => guildId != null && guildId! > 0;

  String get vipDisplayName {
    if (vipLevel <= 0) return 'Chưa kích hoạt';
    if (vipName != null && vipName!.trim().isNotEmpty) return vipName!;
    return 'VIP $vipLevel';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;

    return int.tryParse(text);
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;

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