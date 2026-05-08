class ShopItem {
  final int id;
  final int itemId;
  final String itemCode;
  final String itemName;
  final String? description;
  final String? iconUrl;
  final String? rarity;
  final int priceGold;
  final int pricePremium;
  final int? stockQuantity;
  final int? dailyPurchaseLimit;
  final int? vipRequiredLevel;
  final bool isActive;

  ShopItem({
    required this.id,
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    this.description,
    this.iconUrl,
    this.rarity,
    required this.priceGold,
    required this.pricePremium,
    this.stockQuantity,
    this.dailyPurchaseLimit,
    this.vipRequiredLevel,
    required this.isActive,
  });

  // ✅ FIX LỖI hasImage
  bool get hasImage =>
      iconUrl != null && iconUrl!.isNotEmpty && iconUrl!.startsWith('http');

  factory ShopItem.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();

      final text = value.toString().trim();
      if (text.isEmpty) return 0;

      return double.tryParse(text)?.toInt() ?? 0;
    }

    int? toNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();

      final text = value.toString().trim();
      if (text.isEmpty) return null;

      return double.tryParse(text)?.toInt();
    }

    bool toBool(dynamic value) {
      if (value == true) return true;
      if (value == 1) return true;

      final text = value.toString().toLowerCase().trim();
      return text == '1' || text == 'true';
    }

    return ShopItem(
      id: toInt(map['id']),
      itemId: toInt(map['item_id'] ?? map['itemId']),
      itemCode: (map['item_code'] ?? map['itemCode'] ?? '').toString(),
      itemName: (map['item_name'] ?? map['itemName'] ?? '').toString(),
      description: map['description']?.toString(),
      iconUrl: map['icon_url']?.toString(),
      rarity: map['rarity']?.toString(),
      priceGold: toInt(map['price_gold'] ?? map['priceGold']),
      pricePremium: toInt(map['price_premium'] ?? map['pricePremium']),
      stockQuantity: toNullableInt(map['stock_quantity'] ?? map['stockQuantity']),
      dailyPurchaseLimit:
      toNullableInt(map['daily_purchase_limit'] ?? map['dailyPurchaseLimit']),
      vipRequiredLevel:
      toNullableInt(map['vip_required_level'] ?? map['vipRequiredLevel']),
      isActive: toBool(map['is_active'] ?? map['isActive']),
    );
  }
}