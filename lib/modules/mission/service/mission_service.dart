import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/mission_item.dart';

class MissionService {
  MissionService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<MissionItem>> getMyMissions({String? type}) async {
    final data = await apiClient.get(ApiPaths.myMissions);
    final list = _extractList(data);

    final missions = list
        .whereType<Map>()
        .map((e) => MissionItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (type == null || type.isEmpty || type == 'all') {
      return missions;
    }

    return missions
        .where((item) => item.missionType.toLowerCase() == type.toLowerCase())
        .toList();
  }

  Future<void> claimMissionReward(int missionId) async {
    await apiClient.post(ApiPaths.claimMissionReward(missionId));
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      for (final key in [
        'items',
        'missions',
        'data',
        'rows',
        'results',
        'userMissions',
        'user_missions',
      ]) {
        final value = map[key];
        if (value is List) return value;
        if (value is Map) {
          final nested = _extractList(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }

    return const [];
  }
}
