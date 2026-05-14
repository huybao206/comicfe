import '../../../../core/config/app_env.dart';

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

  bool get hasImage {
    return iconUrl != null && iconUrl!.trim().isNotEmpty;
  }

  bool get isVipItem => (vipRequiredLevel ?? 0) > 0;

  bool get isFree => priceGold <= 0 && pricePremium <= 0;

  String get rarityText {
    final text = rarity?.trim();

    if (text == null || text.isEmpty) return 'common';

    return text;
  }

  factory ShopItem.fromMap(Map<String, dynamic> map) {
    return ShopItem(
      id: _toInt(map['id']),
      itemId: _toInt(map['item_id'] ?? map['itemId']),
      itemCode: (map['item_code'] ?? map['itemCode'] ?? map['code'] ?? '')
          .toString(),
      itemName: (map['item_name'] ??
          map['itemName'] ??
          map['name'] ??
          'Vật phẩm')
          .toString(),
      description: map['description']?.toString(),
      iconUrl: _buildFullImageUrl(
        (map['icon_url'] ??
            map['iconUrl'] ??
            map['image_url'] ??
            map['imageUrl'])
            ?.toString(),
      ),
      rarity: map['rarity']?.toString(),
      priceGold: _toInt(
        map['price_gold'] ??
            map['priceGold'] ??
            map['gold_price'] ??
            map['goldPrice'] ??
            map['gold'] ??
            map['price'],
      ),
      pricePremium: _toInt(
        map['price_premium'] ??
            map['pricePremium'] ??
            map['premium_price'] ??
            map['premiumPrice'] ??
            map['jade'] ??
            map['gem'] ??
            map['diamond'],
      ),
      stockQuantity: _toNullableInt(
        map['stock_quantity'] ?? map['stockQuantity'],
      ),
      dailyPurchaseLimit: _toNullableInt(
        map['daily_purchase_limit'] ?? map['dailyPurchaseLimit'],
      ),
      vipRequiredLevel: _toNullableInt(
        map['vip_required_level'] ?? map['vipRequiredLevel'],
      ),
      isActive: _toBool(map['is_active'] ?? map['isActive'] ?? true),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null' || text == '-') return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null' || text == '-') return null;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;

    final text = value?.toString().toLowerCase().trim();

    if (text == null || text.isEmpty) return true;

    return text == 'true' || text == '1' || text == 'yes' || text == 'active';
  }

  static String? _buildFullImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final value = raw.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final normalized = value.replaceAll('\\', '/');
    final mediaBaseUrl = AppEnv.baseUrl.replaceFirst('/api', '');

    if (normalized.startsWith('/')) {
      return '$mediaBaseUrl$normalized';
    }

    return '$mediaBaseUrl/$normalized';
  }
}