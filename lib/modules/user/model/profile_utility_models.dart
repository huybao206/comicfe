import '../../../core/config/app_env.dart';

class ReadingHistoryItem {
  const ReadingHistoryItem({
    required this.id,
    required this.comicId,
    required this.chapterId,
    required this.comicTitle,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.coverImageUrl,
    required this.progressPercent,
    required this.lastPageNumber,
    required this.lastReadAt,
  });

  final int id;
  final int comicId;
  final int chapterId;
  final String comicTitle;
  final String chapterTitle;
  final double chapterNumber;
  final String? coverImageUrl;
  final double progressPercent;
  final int lastPageNumber;
  final DateTime? lastReadAt;

  factory ReadingHistoryItem.fromMap(Map<String, dynamic> map) {
    return ReadingHistoryItem(
      id: _toInt(map['id']),
      comicId: _toInt(map['comic_id'] ?? map['comicId']),
      chapterId: _toInt(map['chapter_id'] ?? map['chapterId']),
      comicTitle: (map['comic_title'] ?? map['comicTitle'] ?? map['title'] ?? 'Truyện').toString(),
      chapterTitle: (map['chapter_title'] ?? map['chapterTitle'] ?? '').toString(),
      chapterNumber: _toDouble(map['chapter_number'] ?? map['chapterNumber']),
      coverImageUrl: _buildFullImageUrl(
        (map['cover_image_url'] ?? map['coverImageUrl'])?.toString(),
      ),
      progressPercent: _toDouble(map['progress_percent'] ?? map['progressPercent']),
      lastPageNumber: _toInt(map['last_page_number'] ?? map['lastPageNumber']),
      lastReadAt: _toNullableDateTime(map['last_read_at'] ?? map['lastReadAt']),
    );
  }
}

class FollowedComicItem {
  const FollowedComicItem({
    required this.followId,
    required this.comicId,
    required this.title,
    required this.slug,
    required this.coverImageUrl,
    required this.publicationStatus,
    required this.totalViews,
    required this.totalFollows,
    required this.createdAt,
    required this.lastReadAt,
  });

  final int followId;
  final int comicId;
  final String title;
  final String slug;
  final String? coverImageUrl;
  final String publicationStatus;
  final int totalViews;
  final int totalFollows;
  final DateTime? createdAt;
  final DateTime? lastReadAt;

  factory FollowedComicItem.fromMap(Map<String, dynamic> map) {
    return FollowedComicItem(
      followId: _toInt(map['id'] ?? map['follow_id'] ?? map['followId']),
      comicId: _toInt(map['comic_id'] ?? map['comicId']),
      title: (map['title'] ?? map['comic_title'] ?? map['comicTitle'] ?? 'Truyện').toString(),
      slug: (map['slug'] ?? map['comic_slug'] ?? map['comicSlug'] ?? '').toString(),
      coverImageUrl: _buildFullImageUrl(
        (map['cover_image_url'] ?? map['coverImageUrl'])?.toString(),
      ),
      publicationStatus: (map['publication_status'] ?? map['publicationStatus'] ?? '').toString(),
      totalViews: _toInt(map['total_views'] ?? map['totalViews']),
      totalFollows: _toInt(map['total_follows'] ?? map['totalFollows']),
      createdAt: _toNullableDateTime(map['created_at'] ?? map['createdAt']),
      lastReadAt: _toNullableDateTime(map['last_read_at'] ?? map['lastReadAt']),
    );
  }
}

class InventoryData {
  const InventoryData({
    required this.summary,
    required this.items,
  });

  final InventorySummary summary;
  final List<InventoryItem> items;

  factory InventoryData.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    final items = rawItems is List
        ? rawItems
        .whereType<Map>()
        .map((item) => InventoryItem.fromMap(Map<String, dynamic>.from(item)))
        .where((item) => item.itemId > 0)
        .toList()
        : <InventoryItem>[];

    return InventoryData(
      summary: InventorySummary.fromMap(
        map['summary'] is Map
            ? Map<String, dynamic>.from(map['summary'] as Map)
            : <String, dynamic>{},
      ),
      items: items,
    );
  }
}

class InventorySummary {
  const InventorySummary({
    required this.distinctItemCount,
    required this.totalQuantity,
    required this.goldBalance,
    required this.premiumCurrency,
    required this.currentExp,
    required this.totalExpEarned,
    required this.spiritStones,
    required this.combatPower,
    required this.powerScore,
    required this.vipLevelId,
  });

  final int distinctItemCount;
  final int totalQuantity;
  final int goldBalance;
  final int premiumCurrency;
  final int currentExp;
  final int totalExpEarned;
  final int spiritStones;
  final int combatPower;
  final int powerScore;
  final int vipLevelId;

  factory InventorySummary.fromMap(Map<String, dynamic> map) {
    return InventorySummary(
      distinctItemCount: _toInt(map['distinct_item_count'] ?? map['distinctItemCount']),
      totalQuantity: _toInt(map['total_quantity'] ?? map['totalQuantity']),
      goldBalance: _toInt(map['gold_balance'] ?? map['goldBalance']),
      premiumCurrency: _toInt(map['premium_currency'] ?? map['premiumCurrency']),
      currentExp: _toInt(map['current_exp'] ?? map['currentExp']),
      totalExpEarned: _toInt(map['total_exp_earned'] ?? map['totalExpEarned']),
      spiritStones: _toInt(map['spirit_stones'] ?? map['spiritStones']),
      combatPower: _toInt(map['combat_power'] ?? map['combatPower']),
      powerScore: _toInt(map['power_score'] ?? map['powerScore']),
      vipLevelId: _toInt(map['vip_level_id'] ?? map['vipLevelId']),
    );
  }
}

class InventoryItem {
  const InventoryItem({
    required this.inventoryId,
    required this.itemId,
    required this.quantity,
    required this.isBound,
    required this.obtainedFrom,
    required this.expiresAt,
    required this.name,
    required this.code,
    required this.description,
    required this.itemTypeName,
    required this.iconUrl,
    required this.rarity,
    required this.usableInstantly,
    required this.equippable,
    required this.expBonus,
    required this.powerBonus,
    required this.afkBonusPercent,
    required this.vipRequiredLevel,
  });

  final int inventoryId;
  final int itemId;
  final int quantity;
  final bool isBound;
  final String? obtainedFrom;
  final DateTime? expiresAt;
  final String name;
  final String code;
  final String? description;
  final String? itemTypeName;
  final String? iconUrl;
  final String rarity;
  final bool usableInstantly;
  final bool equippable;
  final int expBonus;
  final int powerBonus;
  final double afkBonusPercent;
  final int vipRequiredLevel;

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    final itemMap = map['item'] is Map
        ? Map<String, dynamic>.from(map['item'] as Map)
        : <String, dynamic>{};

    return InventoryItem(
      inventoryId: _toInt(map['id'] ?? map['inventory_id'] ?? map['inventoryId']),
      itemId: _toInt(map['item_id'] ?? map['itemId'] ?? itemMap['id']),
      quantity: _toInt(map['quantity']),
      isBound: _toBool(map['is_bound'] ?? map['isBound']),
      obtainedFrom: (map['obtained_from'] ?? map['obtainedFrom'])?.toString(),
      expiresAt: _toNullableDateTime(map['expires_at'] ?? map['expiresAt']),
      name: (itemMap['name'] ?? map['name'] ?? 'Vật phẩm').toString(),
      code: (itemMap['code'] ?? map['code'] ?? '').toString(),
      description: (itemMap['description'] ?? map['description'])?.toString(),
      itemTypeName: (itemMap['item_type_name'] ?? itemMap['itemTypeName'] ?? map['item_type_name'])?.toString(),
      iconUrl: _buildFullImageUrl(
        (itemMap['icon_url'] ?? itemMap['iconUrl'] ?? map['icon_url'])?.toString(),
      ),
      rarity: (itemMap['rarity'] ?? map['rarity'] ?? 'common').toString(),
      usableInstantly: _toBool(itemMap['usable_instantly'] ?? itemMap['usableInstantly'] ?? map['usable_instantly']),
      equippable: _toBool(itemMap['equippable'] ?? map['equippable']),
      expBonus: _toInt(itemMap['exp_bonus'] ?? itemMap['expBonus'] ?? map['exp_bonus']),
      powerBonus: _toInt(itemMap['power_bonus'] ?? itemMap['powerBonus'] ?? map['power_bonus']),
      afkBonusPercent: _toDouble(itemMap['afk_bonus_percent'] ?? itemMap['afkBonusPercent'] ?? map['afk_bonus_percent']),
      vipRequiredLevel: _toInt(itemMap['vip_required_level'] ?? itemMap['vipRequiredLevel'] ?? map['vip_required_level']),
    );
  }
}

class InventoryUseResult {
  const InventoryUseResult({
    required this.itemName,
    required this.usedQuantity,
    required this.expGain,
    required this.powerGain,
    required this.spiritStoneGain,
  });

  final String itemName;
  final int usedQuantity;
  final int expGain;
  final int powerGain;
  final int spiritStoneGain;

  factory InventoryUseResult.fromMap(Map<String, dynamic> map) {
    final effects = map['applied_effects'] is Map
        ? Map<String, dynamic>.from(map['applied_effects'] as Map)
        : <String, dynamic>{};

    return InventoryUseResult(
      itemName: (map['item_name'] ?? map['itemName'] ?? 'Vật phẩm').toString(),
      usedQuantity: _toInt(map['used_quantity'] ?? map['usedQuantity']),
      expGain: _toInt(effects['exp_gain'] ?? effects['expGain']),
      powerGain: _toInt(effects['power_gain'] ?? effects['powerGain']),
      spiritStoneGain: _toInt(effects['spirit_stone_gain'] ?? effects['spiritStoneGain']),
    );
  }

  String get summaryText {
    final effects = <String>[];
    if (expGain > 0) effects.add('+$expGain EXP');
    if (powerGain > 0) effects.add('+$powerGain lực chiến');
    if (spiritStoneGain > 0) effects.add('+$spiritStoneGain linh thạch');

    if (effects.isEmpty) return 'Đã dùng $usedQuantity $itemName';
    return 'Đã dùng $usedQuantity $itemName: ${effects.join(', ')}';
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();

  final text = value.toString().trim();
  if (text.isEmpty || text == 'null' || text == '-') return 0;

  return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is num) return value.toDouble();

  final text = value.toString().trim();
  if (text.isEmpty || text == 'null' || text == '-') return 0;

  return double.tryParse(text) ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is num) return value.toInt() == 1;

  final text = value?.toString().toLowerCase().trim();
  return text == 'true' || text == '1' || text == 'yes';
}

DateTime? _toNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') return null;

  return DateTime.tryParse(text);
}

String? _buildFullImageUrl(String? raw) {
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
