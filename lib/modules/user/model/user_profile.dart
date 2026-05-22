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

  final String? levelName;
  final String? realmName;
  final int? realmOrder;
  final int? stageNumber;
  final String? stageName;
  final String? stageBand;
  final bool isBreakthroughLevel;
  final int combatPower;

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
    required this.levelName,
    required this.realmName,
    required this.realmOrder,
    required this.stageNumber,
    required this.stageName,
    required this.stageBand,
    required this.isBreakthroughLevel,
    required this.combatPower,
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

    final combatMap = map['combat'] is Map
        ? Map<String, dynamic>.from(map['combat'] as Map)
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

    final parsedLevel = _toInt(
      cultivationMap['level_number'] ??
          cultivationMap['levelNumber'] ??
          cultivationMap['level'] ??
          userMap['level'] ??
          map['level'],
    );

    final parsedStage = _toNullableInt(
      cultivationMap['stage_number'] ??
          cultivationMap['stageNumber'] ??
          cultivationMap['current_stage_number'] ??
          cultivationMap['currentStageNumber'],
    ) ??
        _stageNumberFromLevel(parsedLevel);

    final parsedRealmName = (cultivationMap['realm_name'] ??
        cultivationMap['realmName'] ??
        cultivationMap['current_realm_name'] ??
        cultivationMap['currentRealmName'])
        ?.toString()
        .trim();

    final fallbackRealm = _realmNameFromLevel(parsedLevel);
    final finalRealmName =
    parsedRealmName != null && parsedRealmName.isNotEmpty ? parsedRealmName : fallbackRealm;

    final parsedStageBand = (cultivationMap['stage_band'] ??
        cultivationMap['stageBand'])
        ?.toString()
        .trim();

    final finalStageBand = parsedStageBand != null && parsedStageBand.isNotEmpty
        ? parsedStageBand
        : _stageBandFromStage(parsedStage);

    final parsedStageName = (cultivationMap['stage_name'] ??
        cultivationMap['stageName'] ??
        cultivationMap['current_stage_name'] ??
        cultivationMap['currentStageName'])
        ?.toString()
        .trim();

    final finalStageName = parsedStageName != null && parsedStageName.isNotEmpty
        ? parsedStageName
        : _buildStageName(finalRealmName, finalStageBand, parsedStage);

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

      level: parsedLevel,
      exp: _toInt(
        cultivationMap['current_exp'] ??
            cultivationMap['currentExp'] ??
            cultivationMap['exp'] ??
            userMap['exp'] ??
            map['exp'],
      ),
      expToNextLevel: _toInt(
        cultivationMap['current_level_exp_required'] ??
            cultivationMap['currentLevelExpRequired'] ??
            cultivationMap['exp_required'] ??
            cultivationMap['expRequired'] ??
            cultivationMap['exp_to_next_level'] ??
            cultivationMap['expToNextLevel'] ??
            map['exp_to_next_level'] ??
            map['expToNextLevel'],
      ),
      levelName: (cultivationMap['level_name'] ??
          cultivationMap['levelName'] ??
          map['level_name'] ??
          map['levelName'] ??
          finalStageName)
          ?.toString(),
      realmName: finalRealmName,
      realmOrder: _toNullableInt(
        cultivationMap['realm_order'] ?? cultivationMap['realmOrder'],
      ) ??
          _realmOrderFromLevel(parsedLevel),
      stageNumber: parsedStage,
      stageName: finalStageName,
      stageBand: finalStageBand,
      isBreakthroughLevel: _toBool(
        cultivationMap['is_breakthrough_level'] ??
            cultivationMap['isBreakthroughLevel'],
      ),
      combatPower: _toInt(
        cultivationMap['combat_power'] ??
            cultivationMap['combatPower'] ??
            combatMap['combat_power'] ??
            combatMap['combatPower'] ??
            combatMap['power_score'] ??
            combatMap['powerScore'],
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
    String? levelName,
    String? realmName,
    int? realmOrder,
    int? stageNumber,
    String? stageName,
    String? stageBand,
    bool? isBreakthroughLevel,
    int? combatPower,
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
      levelName: levelName ?? this.levelName,
      realmName: realmName ?? this.realmName,
      realmOrder: realmOrder ?? this.realmOrder,
      stageNumber: stageNumber ?? this.stageNumber,
      stageName: stageName ?? this.stageName,
      stageBand: stageBand ?? this.stageBand,
      isBreakthroughLevel: isBreakthroughLevel ?? this.isBreakthroughLevel,
      combatPower: combatPower ?? this.combatPower,
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

  String get cultivationDisplayName {
    final realm = realmName?.trim();
    final band = stageBand?.trim();
    final stage = stageNumber;

    if (realm != null && realm.isNotEmpty) {
      if (band != null && band.isNotEmpty && stage != null && stage > 0) {
        return '$realm $band • Tầng $stage';
      }
      if (stage != null && stage > 0) {
        return '$realm • Tầng $stage';
      }
      return realm;
    }

    if (levelName != null && levelName!.trim().isNotEmpty) {
      return levelName!.trim();
    }

    if (level > 0) return 'Cấp $level';
    return 'Chưa tu luyện';
  }

  String get cultivationShortLabel {
    if (level > 0 && cultivationDisplayName != 'Cấp $level') {
      return 'Cấp $level • $cultivationDisplayName';
    }
    return cultivationDisplayName;
  }

  String get cultivationCompactLabel {
    final realm = realmName?.trim();
    final band = stageBand?.trim();
    if (realm != null && realm.isNotEmpty && band != null && band.isNotEmpty) {
      return '$realm $band';
    }
    return cultivationDisplayName;
  }

  String get vipDisplayName {
    if (vipLevel <= 0) return 'Chưa kích hoạt';
    if (vipName != null && vipName!.trim().isNotEmpty) return vipName!;
    return 'VIP $vipLevel';
  }

  String get goldText => _formatNumber(gold);
  String get coinText => _formatNumber(coin);
  String get spiritStoneText => _formatNumber(spiritStone);
  String get expText => _formatNumber(exp);
  String get expToNextLevelText => _formatNumber(expToNextLevel);
  String get combatPowerText => _formatNumber(combatPower);

  static String _formatNumber(num value) {
    final integer = value.round();
    final raw = integer.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < raw.length; i++) {
      final positionFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
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

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
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

  static int? _stageNumberFromLevel(int levelNumber) {
    if (levelNumber <= 0) return null;
    return ((levelNumber - 1) % 10) + 1;
  }

  static int? _realmOrderFromLevel(int levelNumber) {
    if (levelNumber <= 0) return null;
    return ((levelNumber - 1) ~/ 10) + 1;
  }

  static String? _realmNameFromLevel(int levelNumber) {
    final order = _realmOrderFromLevel(levelNumber);
    if (order == null || order <= 0) return null;

    const names = <String>[
      'Luyện Khí',
      'Trúc Cơ',
      'Kim Đan',
      'Nguyên Anh',
      'Hóa Thần',
      'Luyện Hư',
      'Hợp Thể',
      'Đại Thừa',
      'Độ Kiếp',
      'Chân Tiên',
      'Kim Tiên',
      'Thái Ất Kim Tiên',
      'Đại La Kim Tiên',
      'Tiên Vương',
      'Tiên Quân',
      'Tiên Đế',
      'Đạo Tổ',
      'Thiên Tôn',
      'Thần Vương',
      'Thần Thánh',
    ];

    if (order > names.length) return 'Cảnh giới $order';
    return names[order - 1];
  }

  static String? _stageBandFromStage(int? stage) {
    if (stage == null || stage <= 0) return null;
    if (stage <= 3) return 'Sơ kỳ';
    if (stage <= 6) return 'Trung kỳ';
    if (stage <= 9) return 'Hậu kỳ';
    return 'Đại viên mãn';
  }

  static String? _buildStageName(String? realm, String? band, int? stage) {
    if (realm == null || realm.trim().isEmpty) return null;
    if (band != null && band.trim().isNotEmpty) return '$realm $band';
    if (stage != null && stage > 0) return '$realm tầng $stage';
    return realm;
  }
}
