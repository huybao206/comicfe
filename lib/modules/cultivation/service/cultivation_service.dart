import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/cultivation_models.dart';

class CultivationService {
  CultivationService({required this.apiClient});

  final ApiClient apiClient;

  Future<CultivationStateData> getMyCultivation() async {
    final data = await apiClient.get(ApiPaths.myCultivation);
    if (data is Map) {
      return CultivationStateData.fromJson(Map<String, dynamic>.from(data));
    }
    return const CultivationStateData(cultivation: {}, currentRule: null, levels: []);
  }

  Future<Map<String, dynamic>> attemptBreakthrough({bool useInsurance = false}) async {
    final data = await apiClient.post(
      ApiPaths.attemptBreakthrough,
      data: {'use_insurance': useInsurance},
    );
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }
}
