import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/shop_item.dart';
import '../provider/shop_provider.dart';
import '../widgets/buy_item_dialog.dart';
import '../widgets/shop_empty_view.dart';
import '../widgets/shop_header.dart';
import '../widgets/shop_item_card.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ShopProvider>().loadShopItems();
    });
  }

  Future<void> _handleBuy(ShopItem item) async {
    final quantity = await showBuyItemDialog(context, item);

    if (quantity == null) return;

    final ok = await context.read<ShopProvider>().buyItem(
      item.id,
      quantity: quantity,
    );

    if (!mounted) return;

    final provider = context.read<ShopProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? 'Mua thành công ${item.itemName}'
              : (provider.errorMessage ?? 'Mua thất bại'),
        ),
      ),
    );

    if (ok) {
      context.read<ShopProvider>().loadShopItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A07),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tiên Các Bảo Khố',
          style: TextStyle(
            color: Color(0xFFF6E7BE),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: () => context.read<ShopProvider>().loadShopItems(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: ShopHeader(),
            ),
            if (shopProvider.isLoading && shopProvider.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFC7962F)),
                ),
              )
            else if (shopProvider.errorMessage != null &&
                shopProvider.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      shopProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE6D4AC),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
            else if (shopProvider.items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: ShopEmptyView(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: shopProvider.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = shopProvider.items[index];
                      return ShopItemCard(
                        item: item,
                        isBuying: shopProvider.isBuying,
                        onBuy: () => _handleBuy(item),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}