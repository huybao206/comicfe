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
              ? 'Mua thành công $quantity x ${item.itemName}'
              : provider.errorMessage ?? 'Mua thất bại',
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

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A07),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF6E7BE)),
        title: const Text(
          'Chi tiết bảo vật',
          style: TextStyle(
            color: Color(0xFFF6E7BE),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          _priceCard(),
          const SizedBox(height: 16),
          _infoCard(),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: provider.isBuying ? null : () => _handleBuy(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC7962F),
                foregroundColor: const Color(0xFF24170B),
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: provider.isBuying
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Color(0xFF24170B),
                ),
              )
                  : const Text(
                'Thu nhận vật phẩm',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B1E12),
            Color(0xFF17110C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7A5A26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _itemImage(),
          const SizedBox(height: 16),
          Text(
            item.itemName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFF6E7BE),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description?.trim().isNotEmpty == true
                ? item.description!
                : 'Một bảo vật quý hiếm dành cho hành giả trên con đường tu tiên.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD7C39A),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemImage() {
    final hasImage = item.iconUrl != null && item.iconUrl!.trim().isNotEmpty;

    return Container(
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        color: const Color(0xFF21170F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF9C742C)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
        item.iconUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderIcon(),
      )
          : _placeholderIcon(),
    );
  }

  Widget _placeholderIcon() {
    return const Center(
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Color(0xFFE8C36D),
        size: 54,
      ),
    );
  }

  Widget _priceCard() {
    return _darkCard(
      title: 'Giá trị vật phẩm',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _infoBox(
                  icon: Icons.monetization_on_outlined,
                  label: 'Giá vàng',
                  value: '${item.priceGold} vàng',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoBox(
                  icon: Icons.diamond_outlined,
                  label: 'Giá ngọc',
                  value: '${item.pricePremium} ngọc',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _infoBox(
                  icon: Icons.stars_rounded,
                  label: 'Phẩm chất',
                  value: item.rarity?.trim().isNotEmpty == true
                      ? item.rarity!
                      : 'common',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoBox(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Yêu cầu VIP',
                  value: 'VIP ${item.vipRequiredLevel ?? 0}+',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return _darkCard(
      title: 'Thông tin chi tiết',
      child: Column(
        children: [
          _infoRow('Mã vật phẩm', item.itemCode.isNotEmpty ? item.itemCode : '-'),
          _infoRow('ID shop', '${item.id}'),
          _infoRow('ID item', '${item.itemId}'),
          _infoRow(
            'Tồn kho',
            item.stockQuantity == null ? 'Không giới hạn' : '${item.stockQuantity}',
          ),
          _infoRow(
            'Giới hạn/ngày',
            item.dailyPurchaseLimit == null
                ? 'Không giới hạn'
                : '${item.dailyPurchaseLimit}',
          ),
          _infoRow('Trạng thái', item.isActive ? 'Đang mở bán' : 'Ngừng bán'),
        ],
      ),
    );
  }

  Widget _darkCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFC7962F),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFF6E7BE),
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF23180F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5E451D)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE0B85C),
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFD5C6A2),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF6E7BE),
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD5C6A2),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFF6E7BE),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}