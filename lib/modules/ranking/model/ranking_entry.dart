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

  final int vipLevel;
  final String? vipName;
  final int vipExp;
  final int totalTopupAmount;

  final int goldBalance;
  final int premiumCurrency;

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
    required this.vipLevel,
    required this.vipName,
    required this.vipExp,
    required this.totalTopupAmount,
    required this.goldBalance,
    required this.premiumCurrency,
  });

  factory RankingEntry.fromMap(Map<String, dynamic> map) {
    final dataMap = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : <String, dynamic>{};

    final userMap = map['user'] is Map
        ? Map<String, dynamic>.from(map['user'] as Map)
        : <String, dynamic>{};

    return RankingEntry(
      rank: _toInt(
        map['rank'] ??
            map['rank_position'] ??
            map['rankPosition'] ??
            dataMap['rank'] ??
            dataMap['rank_position'] ??
            dataMap['rankPosition'],
      ),
      userId: _toInt(
        map['user_id'] ??
            map['userId'] ??
            map['entity_id'] ??
            map['entityId'] ??
            dataMap['user_id'] ??
            dataMap['userId'] ??
            dataMap['entity_id'] ??
            dataMap['entityId'] ??
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
          map['name'] ??
          dataMap['displayName'] ??
          dataMap['display_name'] ??
          dataMap['name'] ??
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
            dataMap['combat_power'] ??
            dataMap['goldBalance'] ??
            dataMap['gold_balance'],
      ),
      combatPower: _toInt(
        map['combatPower'] ??
            map['combat_power'] ??
            dataMap['combatPower'] ??
            dataMap['combat_power'] ??
            dataMap['powerScore'] ??
            dataMap['power_score'],
      ),
      level: _toInt(
        map['level'] ??
            map['levelNumber'] ??
            map['level_number'] ??
            dataMap['level'] ??
            dataMap['levelNumber'] ??
            dataMap['level_number'] ??
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
      vipLevel: _toInt(
        map['vipLevel'] ??
            map['vip_level'] ??
            map['level_number'] ??
            dataMap['vipLevel'] ??
            dataMap['vip_level'] ??
            dataMap['levelNumber'] ??
            dataMap['level_number'],
      ),
      vipName: (map['vipName'] ??
          map['vip_name'] ??
          dataMap['vipName'] ??
          dataMap['vip_name'])
          ?.toString(),
      vipExp: _toInt(
        map['vipExp'] ?? map['vip_exp'] ?? dataMap['vipExp'] ?? dataMap['vip_exp'],
      ),
      totalTopupAmount: _toInt(
        map['totalTopupAmount'] ??
            map['total_topup_amount'] ??
            dataMap['totalTopupAmount'] ??
            dataMap['total_topup_amount'],
      ),
      goldBalance: _toInt(
        map['goldBalance'] ??
            map['gold_balance'] ??
            dataMap['goldBalance'] ??
            dataMap['gold_balance'],
      ),
      premiumCurrency: _toInt(
        map['premiumCurrency'] ??
            map['premium_currency'] ??
            dataMap['premiumCurrency'] ??
            dataMap['premium_currency'],
      ),
    );
  }

  String get name {
    if (displayName.trim().isNotEmpty) return displayName;
    if (username.trim().isNotEmpty) return username;
    return 'Người dùng';
  }

  int get displayScore {
    if (score > 0) return score;
    if (combatPower > 0) return combatPower;
    if (goldBalance > 0) return goldBalance;
    if (vipLevel > 0) return vipLevel;
    if (level > 0) return level;
    return 0;
  }

  String get subtitle {
    final parts = <String>[];

    if (realmName != null && realmName!.trim().isNotEmpty) {
      parts.add(realmName!);
    }

    if (level > 0) {
      parts.add('Cấp $level');
    }

    if (vipName != null && vipName!.trim().isNotEmpty) {
      parts.add(vipName!);
    } else if (vipLevel > 0) {
      parts.add('VIP $vipLevel');
    }

    if (guildName != null && guildName!.trim().isNotEmpty) {
      parts.add(guildName!);
    }

    if (parts.isEmpty && username.isNotEmpty) {
      parts.add('@$username');
    }

    return parts.join(' • ');
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return 0;
    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
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
