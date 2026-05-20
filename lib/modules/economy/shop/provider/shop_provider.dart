import 'package:flutter/material.dart';

import '../model/shop_item.dart';
import '../service/shop_service.dart';

class ShopProvider extends ChangeNotifier {
  final ShopService shopService;

  ShopProvider({required this.shopService});

  bool isLoading = false;
  bool isBuying = false;
  String? errorMessage;
  List<ShopItem> items = [];

  Future<void> loadShopItems() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      items = await shopService.getShopItems();
    } catch (e) {
      errorMessage = _err(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> buyItem(int id, {int quantity = 1}) async {
    if (isBuying) return false;

    try {
      isBuying = true;
      errorMessage = null;
      notifyListeners();

      await shopService.buyItem(
        shopItemId: id,
        quantity: quantity,
      );

      await loadShopItems();
      return true;
    } catch (e) {
      errorMessage = _purchaseErr(e);
      return false;
    } finally {
      isBuying = false;
      notifyListeners();
    }
  }

  String _err(dynamic e) => e.toString().replaceFirst('Exception: ', '');

  String _purchaseErr(dynamic e) {
    final message = _err(e).trim();
    final lower = message.toLowerCase();

    if (lower.contains('không đủ vàng') ||
        lower.contains('khong du vang') ||
        lower.contains('không đủ ngọc') ||
        lower.contains('khong du ngoc') ||
        lower.contains('không đủ premium') ||
        lower.contains('khong du premium') ||
        lower.contains('không đủ tiền') ||
        lower.contains('khong du tien')) {
      return message.startsWith('Không đủ tiền')
          ? message
          : 'Không đủ tiền để mua vật phẩm';
    }

    return message.isEmpty ? 'Không mua được vật phẩm' : message;
  }
}
