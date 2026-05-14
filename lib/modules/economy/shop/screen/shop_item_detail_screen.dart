import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/shop_item.dart';
import '../provider/shop_provider.dart';
import '../widgets/buy_item_dialog.dart';

class ShopItemDetailScreen extends StatelessWidget {
  const ShopItemDetailScreen({
    super.key,
    required this.item,
  });

  final ShopItem item;

  Future<void> _handleBuy(BuildContext context) async {
    final quantity = await showBuyItemDialog(context, item);

    if (quantity == null) return;

    final provider = context.read<ShopProvider>();

    final ok = await provider.buyItem(
      item.id,
      quantity: quantity,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Thu nhận thành công $quantity x ${item.itemName}'
              : provider.errorMessage ?? 'Không mua được vật phẩm',
        ),
      ),
    );

    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final rarityColor = _rarityColor(item.rarityText);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _DetailAppBar(
                item: item,
                rarityColor: rarityColor,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MainInfoCard(
                        item: item,
                        rarityColor: rarityColor,
                      ),
                      const SizedBox(height: 14),
                      _PriceSection(item: item),
                      const SizedBox(height: 14),
                      _DetailInfoSection(item: item),
                      const SizedBox(height: 14),
                      _DescriptionSection(item: item),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBuyBar(
              item: item,
              isBuying: provider.isBuying,
              onBuy: () => _handleBuy(context),
            ),
          ),
        ],
      ),
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
      case 'ssr':
        return const Color(0xFFFFD27A);
      case 'epic':
      case 'sr':
        return const Color(0xFFB58CFF);
      case 'rare':
      case 'r':
        return const Color(0xFF60A5FA);
      case 'uncommon':
        return const Color(0xFF4ADE80);
      default:
        return const Color(0xFFC7962F);
    }
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({
    required this.item,
    required this.rarityColor,
  });

  final ShopItem item;
  final Color rarityColor;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 310,
      pinned: true,
      backgroundColor: const Color(0xFF070B14),
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Color(0xFFFFE9B0)),
      title: const Text(
        'Chi tiết bảo vật',
        style: TextStyle(
          color: Color(0xFFFFE9B0),
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.2,
                  colors: [
                    Color(0xFF533812),
                    Color(0xFF15100B),
                    Color(0xFF070B14),
                  ],
                  stops: [0, 0.48, 1],
                ),
              ),
            ),
            Positioned(
              top: 64,
              right: -52,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rarityColor.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -70,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6574FF).withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 22,
              child: Column(
                children: [
                  _LargeItemImage(
                    iconUrl: item.iconUrl,
                    rarityColor: rarityColor,
                  ),
                  const SizedBox(height: 16),
                  _RarityBadge(
                    text: item.rarityText,
                    color: rarityColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.itemName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFE9B0),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description?.trim().isNotEmpty == true
                        ? item.description!
                        : 'Bảo vật quý hiếm hỗ trợ đạo hữu trên con đường tu luyện.',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFE9D7AE).withOpacity(0.72),
                      fontSize: 13,
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LargeItemImage extends StatelessWidget {
  const _LargeItemImage({
    required this.iconUrl,
    required this.rarityColor,
  });

  final String? iconUrl;
  final Color rarityColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = iconUrl != null && iconUrl!.trim().isNotEmpty;

    return Container(
      width: 126,
      height: 126,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rarityColor.withOpacity(0.95),
            rarityColor.withOpacity(0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21170F),
          borderRadius: BorderRadius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.network(
          iconUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 58,
        color: Color(0xFFE0B85C),
      ),
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  const _MainInfoCard({
    required this.item,
    required this.rarityColor,
  });

  final ShopItem item;
  final Color rarityColor;

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      child: Row(
        children: [
          _MiniInfoBox(
            icon: Icons.inventory_2_outlined,
            label: 'Mã',
            value: item.itemCode.isNotEmpty ? item.itemCode : '-',
            color: rarityColor,
          ),
          const SizedBox(width: 10),
          _MiniInfoBox(
            icon: Icons.workspace_premium_outlined,
            label: 'Yêu cầu',
            value: 'VIP ${item.vipRequiredLevel ?? 0}+',
            color: const Color(0xFFFFD27A),
          ),
          const SizedBox(width: 10),
          _MiniInfoBox(
            icon: Icons.storefront_outlined,
            label: 'Trạng thái',
            value: item.isActive ? 'Đang bán' : 'Đã đóng',
            color: item.isActive
                ? const Color(0xFF4ADE80)
                : const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({
    required this.item,
  });

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Giá trị vật phẩm',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PriceTile(
                  icon: Icons.monetization_on_outlined,
                  title: 'Giá vàng',
                  value: item.isFree ? 'Miễn phí' : '${item.priceGold}',
                  suffix: item.isFree ? '' : 'vàng',
                  color: const Color(0xFFFFD27A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PriceTile(
                  icon: Icons.diamond_outlined,
                  title: 'Giá ngọc',
                  value: '${item.pricePremium}',
                  suffix: 'ngọc',
                  color: const Color(0xFF8FB0FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PriceTile(
                  icon: Icons.stars_rounded,
                  title: 'Phẩm chất',
                  value: item.rarityText.toUpperCase(),
                  suffix: '',
                  color: const Color(0xFFC7962F),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PriceTile(
                  icon: Icons.card_giftcard_rounded,
                  title: 'Mua/ngày',
                  value: item.dailyPurchaseLimit == null
                      ? 'Không giới hạn'
                      : '${item.dailyPurchaseLimit}',
                  suffix: '',
                  color: const Color(0xFF4ADE80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailInfoSection extends StatelessWidget {
  const _DetailInfoSection({
    required this.item,
  });

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Thông tin chi tiết',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            label: 'ID shop',
            value: '${item.id}',
          ),
          _InfoRow(
            label: 'ID vật phẩm',
            value: '${item.itemId}',
          ),
          _InfoRow(
            label: 'Tồn kho',
            value: item.stockQuantity == null
                ? 'Không giới hạn'
                : '${item.stockQuantity}',
          ),
          _InfoRow(
            label: 'Giới hạn/ngày',
            value: item.dailyPurchaseLimit == null
                ? 'Không giới hạn'
                : '${item.dailyPurchaseLimit}',
          ),
          _InfoRow(
            label: 'Yêu cầu VIP',
            value: 'VIP ${item.vipRequiredLevel ?? 0}+',
          ),
          _InfoRow(
            label: 'Trạng thái',
            value: item.isActive ? 'Đang mở bán' : 'Ngừng bán',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.item,
  });

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Mô tả bảo vật',
      icon: Icons.menu_book_outlined,
      child: Text(
        item.description?.trim().isNotEmpty == true
            ? item.description!
            : 'Bảo vật này chưa có mô tả chi tiết. Có thể dùng để hỗ trợ tu luyện, tăng tài nguyên hoặc mở rộng sức mạnh nhân vật.',
        style: TextStyle(
          color: const Color(0xFFE9D7AE).withOpacity(0.72),
          fontSize: 13.5,
          height: 1.5,
        ),
      ),
    );
  }
}

class _BottomBuyBar extends StatelessWidget {
  const _BottomBuyBar({
    required this.item,
    required this.isBuying,
    required this.onBuy,
  });

  final ShopItem item;
  final bool isBuying;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1020),
        border: const Border(
          top: BorderSide(color: Color(0xFF1E2A44)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.32),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF11182A),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFF263756)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: Color(0xFFFFD27A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.isFree
                            ? 'Miễn phí'
                            : '${item.priceGold} vàng / ${item.pricePremium} ngọc',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFFE9B0),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: isBuying ? null : onBuy,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A02F),
                  disabledBackgroundColor: const Color(0xFF514225),
                  foregroundColor: const Color(0xFF211407),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: isBuying
                    ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Color(0xFF211407),
                  ),
                )
                    : const Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded, size: 19),
                    SizedBox(width: 7),
                    Text(
                      'Thu nhận',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  const _DarkCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF263756)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A02F).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4A02F).withOpacity(0.42),
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFFD27A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _MiniInfoBox extends StatelessWidget {
  const _MiniInfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 78,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFF151D31),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.42),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFE9B0),
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.suffix,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF151D31),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.46),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  suffix.isEmpty ? value : '$value $suffix',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 10,
        top: isLast ? 0 : 0,
      ),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.07),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFFFE9B0),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RarityBadge extends StatelessWidget {
  const _RarityBadge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}