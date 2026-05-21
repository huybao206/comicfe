import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/guild.dart';
import '../model/guild_member.dart';

class GuildService {
  GuildService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<Map<String, dynamic>?> getMyGuildProfile() async {
    final data = await apiClient.get(ApiPaths.myGuild);

    if (data == null) return null;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['guild'] is Map) return map;
      if (map['data'] is Map) return Map<String, dynamic>.from(map['data'] as Map);
    }

    return null;
  }

  Future<List<Guild>> getGuilds() async {
    final data = await apiClient.get(ApiPaths.guilds);

    final rawList = _extractList(
      data,
      keys: const [
        'items',
        'data',
        'rows',
        'results',
        'guilds',
      ],
    );

    return rawList
        .whereType<Map>()
        .map((e) => Guild.fromMap(Map<String, dynamic>.from(e)))
        .where((guild) => guild.id > 0)
        .toList();
  }

  Future<Map<String, dynamic>> getGuildProfile(int guildId) async {
    final data = await apiClient.get(ApiPaths.guildDetail(guildId));

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['data'] is Map) return Map<String, dynamic>.from(map['data'] as Map);
      return map;
    }

    throw Exception('Dữ liệu guild không hợp lệ');
  }

  Future<Guild> getGuildDetail(int guildId) async {
    final map = await getGuildProfile(guildId);

    if (map['guild'] is Map) {
      return Guild.fromMap(map);
    }

    return Guild.fromMap(map);
  }

  Future<List<GuildMember>> getGuildMembers(int guildId) async {
    final data = await apiClient.get(ApiPaths.guildMembers(guildId));

    final rawList = _extractList(
      data,
      keys: const [
        'items',
        'data',
        'rows',
        'results',
        'members',
      ],
    );

    return rawList
        .whereType<Map>()
        .map((e) => GuildMember.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> createGuild({
    required String name,
    String? slug,
    String? description,
  }) async {
    final data = await apiClient.post(
      ApiPaths.guilds,
      data: {
        'name': name,
        if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
        'description': description,
      },
    );

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }

      return map;
    }

    throw Exception('Tạo guild thất bại');
  }

  Future<Map<String, dynamic>> joinGuild(int guildId) async {
    final data = await apiClient.post(ApiPaths.guildJoinRequests(guildId));

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }

      return map;
    }

    throw Exception('Gửi yêu cầu tham gia thất bại');
  }


  Future<Map<String, dynamic>> leaveGuild(int guildId) async {
    final data = await apiClient.post(ApiPaths.guildLeave(guildId));
    return _extractMap(data, fallbackMessage: 'Rời bang thất bại');
  }

  Future<Map<String, dynamic>> disbandGuild(int guildId) async {
    final data = await apiClient.post(ApiPaths.guildDisband(guildId));
    return _extractMap(data, fallbackMessage: 'Giải tán bang thất bại');
  }

  Future<Map<String, dynamic>> checkinGuild(int guildId) async {
    final data = await apiClient.post(ApiPaths.guildCheckin(guildId));
    return _extractMap(data, fallbackMessage: 'Điểm danh bang thất bại');
  }

  Future<Map<String, dynamic>> contributeGuild(int guildId) async {
    final data = await apiClient.post(ApiPaths.guildContribute(guildId));
    return _extractMap(data, fallbackMessage: 'Cống hiến bang thất bại');
  }


  Future<Map<String, dynamic>> updateGuildProfile({
    required int guildId,
    required String name,
    String? logoUrl,
    String? description,
    String? announcement,
    int? memberLimit,
    String? joinRequirementText,
    int? joinMinLevel,
    int? joinMinPower,
  }) async {
    final data = await apiClient.put(
      ApiPaths.guildUpdate(guildId),
      data: {
        'name': name,
        'logo_url': logoUrl,
        'description': description,
        'announcement': announcement,
        'member_limit': memberLimit,
        'join_requirement_text': joinRequirementText,
        'join_min_level': joinMinLevel,
        'join_min_power': joinMinPower,
      },
    );

    return _extractMap(data, fallbackMessage: 'Cập nhật hồ sơ bang thất bại');
  }

  Future<Map<String, dynamic>> updateMemberRole({
    required int guildId,
    required int memberId,
    required String roleCode,
  }) async {
    final data = await apiClient.put(
      ApiPaths.guildMemberRole(guildId, memberId),
      data: {'role_code': roleCode},
    );

    return _extractMap(data, fallbackMessage: 'Cập nhật chức vụ thành viên thất bại');
  }

  Map<String, dynamic> _extractMap(
      dynamic data, {
        required String fallbackMessage,
      }) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }

      return map;
    }

    throw Exception(fallbackMessage);
  }

  List _extractList(
      dynamic data, {
        required List<String> keys,
      }) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      for (final key in keys) {
        final value = map[key];

        if (value is List) {
          return value;
        }

        if (value is Map) {
          final nested = Map<String, dynamic>.from(value);

          if (nested['items'] is List) return nested['items'] as List;
          if (nested['rows'] is List) return nested['rows'] as List;
          if (nested['results'] is List) return nested['results'] as List;
          if (nested['guilds'] is List) return nested['guilds'] as List;
          if (nested['members'] is List) return nested['members'] as List;
        }
      }
    }

    return const [];
  }
}
