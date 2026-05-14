import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/guild.dart';
import '../model/guild_member.dart';

class GuildService {
  GuildService({
    required this.apiClient,
  });

  final ApiClient apiClient;

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
        .map(
          (e) => Guild.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .where((guild) => guild.id > 0)
        .toList();
  }

  Future<Guild> getGuildDetail(int guildId) async {
    final data = await apiClient.get(ApiPaths.guildDetail(guildId));

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['data'] is Map) {
        return Guild.fromMap(
          Map<String, dynamic>.from(map['data'] as Map),
        );
      }

      if (map['guild'] is Map) {
        return Guild.fromMap(
          Map<String, dynamic>.from(map['guild'] as Map),
        );
      }

      return Guild.fromMap(map);
    }

    throw Exception('Dữ liệu guild không hợp lệ');
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
        .map(
          (e) => GuildMember.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<Map<String, dynamic>> createGuild({
    required String name,
    required String slug,
    String? description,
  }) async {
    final data = await apiClient.post(
      ApiPaths.guilds,
      data: {
        'name': name,
        'slug': slug,
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