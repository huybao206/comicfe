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

    final rawList = _extractList(data);

    return rawList
        .whereType<Map>()
        .map(
          (e) => RankingType.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .where((type) => type.typeCode.trim().isNotEmpty)
        .toList();
  }

  Future<List<RankingEntry>> getRankingByType(
      String typeCode, {
        int page = 1,
        int limit = 50,
      }) async {
    final data = await apiClient.get(
      ApiPaths.rankingByType(typeCode),
      queryParameters: {
        'page': page,
        'limit': limit,
        'preferSnapshot': false,
      },
    );

    final rawList = _extractList(data);

    return rawList
        .whereType<Map>()
        .map(
          (e) => RankingEntry.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<RankingEntry?> getMyRankingByType(String typeCode) async {
    try {
      final data = await apiClient.get(
        ApiPaths.myRankingByType(typeCode),
        queryParameters: const {'preferSnapshot': false},
      );

      if (data == null) return null;

      if (data is Map) {
        if (data.isEmpty) return null;

        return RankingEntry.fromMap(
          Map<String, dynamic>.from(data),
        );
      }

      return null;
    } catch (_) {

      return null;
    }
  }

  List _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      if (data['items'] is List) return data['items'] as List;
      if (data['data'] is List) return data['data'] as List;
      if (data['rankings'] is List) return data['rankings'] as List;
      if (data['types'] is List) return data['types'] as List;
      if (data['rows'] is List) return data['rows'] as List;
      if (data['results'] is List) return data['results'] as List;
    }

    return const [];
  }
}