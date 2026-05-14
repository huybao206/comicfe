import 'package:flutter/material.dart';

import '../model/shop_item.dart';

class ShopItemCard extends StatelessWidget {
  const ShopItemCard({
    super.key,
    required this.item,
    required this.isBuying,
    required this.onTap,
  });

  final ShopItem item;
  final bool isBuying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(item.rarityText);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF130D08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: rarityColor.withOpacity(0.58)),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -28,
                top: -28,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rarityColor.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ItemImage(
                      iconUrl: item.iconUrl,
                      rarityColor: rarityColor,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.itemName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFF6E7BE),
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _RarityBadge(
                                text: item.rarityText,
                                color: rarityColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description?.trim().isNotEmpty == true
                                ? item.description!
                                : 'Bảo vật quý hiếm hỗ trợ đạo hữu tu luyện.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFFE9D7AE).withOpacity(0.70),
                              fontSize: 12.5,
                              height: 1.42,
                            ),
                          ),
                          const SizedBox(height: 11),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _InfoChip(
                                icon: Icons.monetization_on_outlined,
                                text: item.isFree
                                    ? 'Miễn phí'
                                    : '${item.priceGold} vàng',
                                color: const Color(0xFFFFD27A),
                              ),
                              _InfoChip(
                                icon: Icons.diamond_outlined,
                                text: '${item.pricePremium} ngọc',
                                color: const Color(0xFF8FB0FF),
                              ),
                              _InfoChip(
                                icon: Icons.workspace_premium_outlined,
                                text: 'VIP ${item.vipRequiredLevel ?? 0}+',
                                color: const Color(0xFFFFD27A),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.stockQuantity == null
                                      ? 'Kho: không giới hạn'
                                      : 'Kho: ${item.stockQuantity}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.42),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                height: 38,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD27A),
                                      Color(0xFFD4A02F),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4A02F)
                                          .withOpacity(0.20),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      'Xem',
                                      style: TextStyle(
                                        color: Color(0xFF211407),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Color(0xFF211407),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

class _ItemImage extends StatelessWidget {
  const _ItemImage({
    required this.iconUrl,
    required this.rarityColor,
  });

  final String? iconUrl;
  final Color rarityColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = iconUrl != null && iconUrl!.trim().isNotEmpty;

    return Container(
      width: 86,
      height: 86,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rarityColor.withOpacity(0.9),
            rarityColor.withOpacity(0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21170F),
          borderRadius: BorderRadius.circular(18),
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
        size: 38,
        color: Color(0xFFE0B85C),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.52)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF23180F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE9D7AE),
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}