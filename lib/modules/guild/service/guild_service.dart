import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/guild.dart';
import '../model/guild_donation.dart';
import '../model/guild_join_request.dart';
import '../model/guild_member.dart';

class GuildService {
  GuildService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<Guild>> getGuilds() async {
    final data = await apiClient.get(ApiPaths.guilds);

    List rawList = [];

    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'];
    }

    return rawList
        .map((e) => Guild.fromMap(Map<String, dynamic>.from(e as Map)))
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

    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }

    return Map<String, dynamic>.from(data as Map);
  }

  Future<Guild> getGuildDetail(int guildId) async {
    final data = await apiClient.get(ApiPaths.guildDetail(guildId));

    if (data is Map && data['data'] is Map) {
      return Guild.fromMap(Map<String, dynamic>.from(data['data'] as Map));
    }

    return Guild.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<List<GuildMember>> getGuildMembers(int guildId) async {
    final data = await apiClient.get(ApiPaths.guildMembers(guildId));

    List rawList = [];

    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'];
    }

    return rawList
        .map((e) => GuildMember.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<GuildJoinRequest>> getGuildJoinRequests(int guildId) async {
    final data = await apiClient.get(ApiPaths.guildJoinRequests(guildId));

    List rawList = [];

    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'];
    }

    return rawList
        .map((e) =>
        GuildJoinRequest.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<GuildDonation>> getGuildDonations(int guildId) async {
    final data = await apiClient.get(ApiPaths.guildDonations(guildId));

    List rawList = [];

    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'];
    }

    return rawList
        .map((e) => GuildDonation.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Map<String, dynamic>> joinGuild(int guildId) async {
    final data = await apiClient.post(ApiPaths.guildJoinRequests(guildId));

    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }

    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> donateGuild({
    required int guildId,
    required int contributionPoints,
  }) async {
    final data = await apiClient.post(
      ApiPaths.guildDonations(guildId),
      data: {
        'contributionPoints': contributionPoints,
      },
    );

    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }

    return Map<String, dynamic>.from(data as Map);
  }
}