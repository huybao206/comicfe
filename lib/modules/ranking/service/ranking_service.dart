import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/ranking_entry.dart';
import '../model/ranking_type.dart';

class RankingService {
  RankingService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<RankingType>> getRankingTypes() async {
    final data = await apiClient.get(ApiPaths.rankingTypes);

    List rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'];
    }

    return rawList
        .map((e) => RankingType.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<RankingEntry>> getRankingByType(String typeCode) async {
    final data = await apiClient.get(ApiPaths.rankingByType(typeCode));

    List rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'];
    } else if (data is Map && data['items'] is List) {
      rawList = data['items'];
    }

    return rawList
        .map((e) => RankingEntry.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<RankingEntry?> getMyRankingByType(String typeCode) async {
    final data = await apiClient.get(ApiPaths.myRankingByType(typeCode));

    if (data is Map && data['data'] is Map) {
      return RankingEntry.fromMap(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    }

    if (data is Map) {
      return RankingEntry.fromMap(Map<String, dynamic>.from(data));
    }

    return null;
  }
}