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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF17110C),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF735624)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ItemImage(iconUrl: item.iconUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          color: Color(0xFFF6E7BE),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description?.trim().isNotEmpty == true
                            ? item.description!
                            : 'Một bảo vật quý hiếm dành cho hành giả trên con đường tu tiên.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD5C6A2),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(
                            icon: Icons.monetization_on_outlined,
                            text: '${item.priceGold} vàng',
                          ),
                          _infoChip(
                            icon: Icons.diamond_outlined,
                            text: '${item.pricePremium} ngọc',
                          ),
                          if (item.rarity != null &&
                              item.rarity!.trim().isNotEmpty)
                            _infoChip(
                              icon: Icons.stars_rounded,
                              text: item.rarity!,
                            ),
                          _infoChip(
                            icon: Icons.workspace_premium_outlined,
                            text: 'VIP ${item.vipRequiredLevel ?? 0}+',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.visibility_outlined, size: 17),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFC7962F),
                            foregroundColor: const Color(0xFF24170B),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          label: const Text(
                            'Xem chi tiết',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({
    required this.iconUrl,
  });

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = iconUrl != null && iconUrl!.trim().isNotEmpty;

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7B5C28)),
        color: const Color(0xFF21170F),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: hasImage
            ? Image.network(
          iconUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _ItemPlaceholder(),
        )
            : const _ItemPlaceholder(),
      ),
    );
  }
}

class _ItemPlaceholder extends StatelessWidget {
  const _ItemPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 36,
        color: Color(0xFFE0B85C),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF23180F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF5E451D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFE0B85C)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE9D7AE),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _infoChip({
  required IconData icon,
  required String text,
}) {
  return _InfoChip(icon: icon, text: text);
}