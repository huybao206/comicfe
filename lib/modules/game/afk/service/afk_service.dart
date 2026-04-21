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

    List rawList = [];

    if (response is List) {
      rawList = response;
    } else if (response is Map && response['data'] is List) {
      rawList = response['data'];
    }

    return rawList
        .map((e) => AfkConfig.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<AfkSession> startAfkSession() async {
    final response = await apiClient.post(ApiPaths.afkSessions);

    if (response is Map && response['data'] is Map) {
      return AfkSession.fromMap(
        Map<String, dynamic>.from(response['data'] as Map),
      );
    }

    return AfkSession.fromMap(Map<String, dynamic>.from(response as Map));
  }

  Future<AfkSession> finishAfkSession({
    required int sessionId,
  }) async {
    final response = await apiClient.post(ApiPaths.finishAfkSession(sessionId));

    if (response is Map && response['data'] is Map) {
      return AfkSession.fromMap(
        Map<String, dynamic>.from(response['data'] as Map),
      );
    }

    return AfkSession.fromMap(Map<String, dynamic>.from(response as Map));
  }

  Future<AfkClaimResult> claimAfkSession({
    required int sessionId,
  }) async {
    final response = await apiClient.post(ApiPaths.claimAfkSession(sessionId));

    if (response is Map && response['data'] is Map) {
      return AfkClaimResult.fromMap(
        Map<String, dynamic>.from(response['data'] as Map),
      );
    }

    return AfkClaimResult.fromMap(
      Map<String, dynamic>.from(response as Map),
    );
  }
}