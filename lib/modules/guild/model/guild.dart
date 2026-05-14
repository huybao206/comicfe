import '../../../core/config/app_env.dart';

class Guild {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;
  final int? level;
  final int? guildPower;
  final String? guildStatus;
  final String? leaderName;

  Guild({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
    this.level,
    this.guildPower,
    this.guildStatus,
    this.leaderName,
  });

  factory Guild.fromMap(Map<String, dynamic> map) {
    return Guild(
      id: _toInt(map['id'] ?? map['guild_id'] ?? map['guildId']),
      name: (map['name'] ??
          map['guild_name'] ??
          map['guildName'] ??
          'Tông môn')
          .toString(),
      slug: (map['slug'] ?? map['guild_slug'] ?? map['guildSlug'] ?? '')
          .toString(),
      description: map['description']?.toString(),
      logoUrl: _buildFullImageUrl(
        (map['logo_url'] ??
            map['logoUrl'] ??
            map['image_url'] ??
            map['imageUrl'])
            ?.toString(),
      ),
      level: _toNullableInt(map['level'] ?? map['guild_level']),
      guildPower: _toNullableInt(
        map['guild_power'] ?? map['guildPower'] ?? map['power'],
      ),
      guildStatus: (map['guild_status'] ??
          map['guildStatus'] ??
          map['status'])
          ?.toString(),
      leaderName: (map['leader_name'] ??
          map['leaderName'] ??
          map['owner_name'] ??
          map['ownerName'])
          ?.toString(),
    );
  }

  bool get hasLogo => logoUrl != null && logoUrl!.trim().isNotEmpty;

  bool get hasLeader =>
      leaderName != null && leaderName!.trim().isNotEmpty;

  bool get hasStatus =>
      guildStatus != null && guildStatus!.trim().isNotEmpty;

  String get displayStatus {
    if (!hasStatus) return 'Đang hoạt động';
    return guildStatus!;
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