import '../../../core/config/app_env.dart';

class RankingEntry {
  final int rank;
  final int userId;
  final String username;
  final String displayName;
  final String? avatarUrl;

  final int score;
  final int combatPower;
  final int level;
  final String? realmName;
  final String? guildName;

  const RankingEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.score,
    required this.combatPower,
    required this.level,
    required this.realmName,
    required this.guildName,
  });

  factory RankingEntry.fromMap(Map<String, dynamic> map) {
    final dataMap = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : <String, dynamic>{};

    final userMap = map['user'] is Map
        ? Map<String, dynamic>.from(map['user'] as Map)
        : <String, dynamic>{};

    return RankingEntry(
      rank: _toInt(map['rank'] ?? dataMap['rank']),
      userId: _toInt(
        map['user_id'] ??
            map['userId'] ??
            dataMap['user_id'] ??
            dataMap['userId'] ??
            dataMap['id'] ??
            userMap['id'],
      ),
      username: (map['username'] ??
          dataMap['username'] ??
          userMap['username'] ??
          '')
          .toString(),
      displayName: (map['displayName'] ??
          map['display_name'] ??
          dataMap['displayName'] ??
          dataMap['display_name'] ??
          userMap['displayName'] ??
          userMap['display_name'] ??
          dataMap['username'] ??
          userMap['username'] ??
          'Người dùng')
          .toString(),
      avatarUrl: _buildFullImageUrl(
        (map['avatarUrl'] ??
            map['avatar_url'] ??
            dataMap['avatarUrl'] ??
            dataMap['avatar_url'] ??
            userMap['avatarUrl'] ??
            userMap['avatar_url'])
            ?.toString(),
      ),
      score: _toInt(
        map['score'] ??
            map['scoreValue'] ??
            map['score_value'] ??
            dataMap['score'] ??
            dataMap['scoreValue'] ??
            dataMap['score_value'] ??
            dataMap['combatPower'] ??
            dataMap['combat_power'],
      ),
      combatPower: _toInt(
        map['combatPower'] ??
            map['combat_power'] ??
            dataMap['combatPower'] ??
            dataMap['combat_power'],
      ),
      level: _toInt(
        map['level'] ??
            dataMap['level'] ??
            dataMap['userLevel'] ??
            dataMap['user_level'],
      ),
      realmName: (map['realmName'] ??
          map['realm_name'] ??
          dataMap['realmName'] ??
          dataMap['realm_name'])
          ?.toString(),
      guildName: (map['guildName'] ??
          map['guild_name'] ??
          dataMap['guildName'] ??
          dataMap['guild_name'])
          ?.toString(),
    );
  }

  // Getter này để các UI cũ đang gọi entry.name không bị lỗi.
  String get name {
    if (displayName.trim().isNotEmpty) return displayName;
    if (username.trim().isNotEmpty) return username;
    return 'Người dùng';
  }

  // Getter này để UI cũ dùng entry.score vẫn chạy,
  // còn UI mới có thể dùng displayScore.
  int get displayScore {
    if (score > 0) return score;
    if (combatPower > 0) return combatPower;
    return 0;
  }

  String get subtitle {
    final parts = <String>[];

    if (realmName != null && realmName!.trim().isNotEmpty) {
      parts.add(realmName!);
    }

    if (guildName != null && guildName!.trim().isNotEmpty) {
      parts.add(guildName!);
    }

    if (level > 0) {
      parts.add('Lv.$level');
    }

    if (parts.isEmpty && username.isNotEmpty) {
      parts.add('@$username');
    }

    return parts.join(' • ');
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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