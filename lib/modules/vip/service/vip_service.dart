import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/my_vip.dart';
import '../model/vip_feature.dart';
import '../model/vip_level.dart';

class VipService {
  VipService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<VipLevel>> getVipLevels() async {
    final data = await apiClient.get(ApiPaths.vipLevels);

    List items = [];
    if (data is List) {
      items = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      items = (map['items'] ?? map['levels'] ?? map['data'] ?? []) as List;
    }

    return items
        .map((e) => VipLevel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<VipFeature>> getVipFeatures() async {
    final data = await apiClient.get(ApiPaths.vipFeatures);

    List items = [];
    if (data is List) {
      items = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      items = (map['items'] ?? map['features'] ?? map['data'] ?? []) as List;
    }

    return items
        .map((e) => VipFeature.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<MyVip?> getMyVip() async {
    final data = await apiClient.get(ApiPaths.vipMe);

    if (data is Map) {
      return MyVip.fromMap(Map<String, dynamic>.from(data));
    }

    return null;
  }
}