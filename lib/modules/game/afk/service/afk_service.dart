import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../model/afk_claim_result.dart';
import '../model/afk_config.dart';
import '../model/afk_session.dart';

class AfkService {
  AfkService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<AfkConfig>> getAfkConfigs() async {
    final response = await apiClient.get(ApiPaths.afkConfigs);

    final rawList = _extractList(response);

    return rawList
        .whereType<Map>()
        .map(
          (e) => AfkConfig.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<AfkSession?> getRunningSession() async {
    final response = await apiClient.get(ApiPaths.runningAfkSession);

    if (response == null) return null;

    if (response is Map) {
      return AfkSession.fromMap(
        Map<String, dynamic>.from(response),
      );
    }

    return null;
  }

  Future<AfkSession> startAfkSession() async {
    final response = await apiClient.post(ApiPaths.afkSessions);

    return AfkSession.fromMap(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<AfkSession> finishAfkSession({
    required int sessionId,
  }) async {
    final response = await apiClient.post(
      ApiPaths.finishAfkSession(sessionId),
    );

    return AfkSession.fromMap(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<AfkClaimResult> claimAfkSession({
    required int sessionId,
  }) async {
    final response = await apiClient.post(
      ApiPaths.claimAfkSession(sessionId),
    );

    return AfkClaimResult.fromMap(
      Map<String, dynamic>.from(response as Map),
    );
  }

  List _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['items'] is List) return map['items'] as List;
      if (map['data'] is List) return map['data'] as List;
      if (map['rows'] is List) return map['rows'] as List;
    }

    return const [];
  }
}