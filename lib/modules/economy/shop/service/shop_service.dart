import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../model/shop_item.dart';

class ShopService {
  ShopService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<ShopItem>> getShopItems() async {
    final response = await apiClient.get(ApiPaths.shopItems);

    final rawList = _extractList(response);

    return rawList
        .whereType<Map>()
        .map(
          (e) => ShopItem.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .where((e) => e.isActive)
        .toList();
  }

  Future<Map<String, dynamic>> buyItem({
    required int shopItemId,
    required int quantity,
  }) async {
    final response = await apiClient.post(
      ApiPaths.buyShopItem(shopItemId),
      data: {
        'quantity': quantity,
      },
    );

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Server response error');
  }

  List _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['items'] is List) return map['items'] as List;
      if (map['data'] is List) return map['data'] as List;
      if (map['rows'] is List) return map['rows'] as List;
      if (map['results'] is List) return map['results'] as List;
      if (map['shopItems'] is List) return map['shopItems'] as List;
      if (map['shop_items'] is List) return map['shop_items'] as List;

      if (map['data'] is Map) {
        final nested = Map<String, dynamic>.from(map['data'] as Map);

        if (nested['items'] is List) return nested['items'] as List;
        if (nested['rows'] is List) return nested['rows'] as List;
        if (nested['results'] is List) return nested['results'] as List;
        if (nested['shopItems'] is List) return nested['shopItems'] as List;
        if (nested['shop_items'] is List) return nested['shop_items'] as List;
      }
    }

    return const [];
  }
}