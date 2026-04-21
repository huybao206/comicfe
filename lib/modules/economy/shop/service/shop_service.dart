import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../model/shop_item.dart';

class ShopService {
  final ApiClient apiClient;

  ShopService({required this.apiClient});

  Future<List<ShopItem>> getShopItems() async {
    final response = await apiClient.get(ApiPaths.shopItems);

    List rawList = [];

    if (response is List) {
      rawList = response;
    } else if (response is Map && response['data'] is List) {
      rawList = response['data'];
    }

    return rawList
        .map((e) => ShopItem.fromMap(Map<String, dynamic>.from(e)))
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
}