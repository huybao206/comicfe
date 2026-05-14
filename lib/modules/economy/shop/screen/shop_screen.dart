import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/shop_item.dart';
import '../provider/shop_provider.dart';
import '../widgets/shop_empty_view.dart';
import '../widgets/shop_header.dart';
import '../widgets/shop_item_card.dart';
import 'shop_item_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();

  int selectedFilterIndex = 0;

  final filters = const [
    _ShopFilter('Tất cả', Icons.inventory_2_outlined),
    _ShopFilter('Miễn phí', Icons.card_giftcard_rounded),
    _ShopFilter('Vàng', Icons.monetization_on_outlined),
    _ShopFilter('Ngọc', Icons.diamond_outlined),
    _ShopFilter('VIP', Icons.workspace_premium_outlined),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ShopProvider>().loadShopItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDetail(ShopItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopItemDetailScreen(item: item),
      ),
    );

    if (!mounted) return;

    context.read<ShopProvider>().loadShopItems();
  }

  List<ShopItem> _filterItems(List<ShopItem> source) {
    final keyword = _searchController.text.trim().toLowerCase();

    Iterable<ShopItem> result = source;

    if (keyword.isNotEmpty) {
      result = result.where((item) {
        final name = item.itemName.toLowerCase();
        final desc = item.description?.toLowerCase() ?? '';
        final code = item.itemCode.toLowerCase();

        return name.contains(keyword) ||
            desc.contains(keyword) ||
            code.contains(keyword);
      });
    }

    switch (selectedFilterIndex) {
      case 1:
        result = result.where((item) => item.isFree);
        break;
      case 2:
        result = result.where((item) => item.priceGold > 0);
        break;
      case 3:
        result = result.where((item) => item.pricePremium > 0);
        break;
      case 4:
        result = result.where((item) => item.isVipItem);
        break;
    }

    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final visibleItems = _filterItems(shopProvider.items);

    final freeCount = shopProvider.items.where((e) => e.isFree).length;
    final vipCount = shopProvider.items.where((e) => e.isVipItem).length;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: RefreshIndicator(
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        onRefresh: () => context.read<ShopProvider>().loadShopItems(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ShopHeader(
                totalItems: shopProvider.items.length,
                freeItems: freeCount,
                vipItems: vipCount,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: _searchBox(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: _filterRow(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _sectionHeader(
                  title: 'Bảo vật đang mở',
                  action: '${visibleItems.length} món',
                ),
              ),
            ),
            if (shopProvider.isLoading && shopProvider.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4A02F),
                  ),
                ),
              )
            else if (shopProvider.errorMessage != null &&
                shopProvider.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
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
              else if (visibleItems.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NoResultView(
                      onClear: () {
                        setState(() {
                          selectedFilterIndex = 0;
                          _searchController.clear();
                        });
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                    sliver: SliverList.separated(
                      itemCount: visibleItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = visibleItems[index];

                        return ShopItemCard(
                          item: item,
                          isBuying: shopProvider.isBuying,
                          onTap: () => _openDetail(item),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFFD4A02F),
        decoration: InputDecoration(
          hintText: 'Tìm bảo vật, linh thạch, đan dược...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 13.5,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.68),
          ),
          suffixIcon: _searchController.text.trim().isEmpty
              ? const Icon(
            Icons.tune_rounded,
            color: Color(0xFFD4A02F),
          )
              : IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFFD4A02F),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final item = filters[index];
          final selected = selectedFilterIndex == index;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                selectedFilterIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                  colors: [
                    Color(0xFFFFD27A),
                    Color(0xFFD4A02F),
                  ],
                )
                    : null,
                color: selected ? null : const Color(0xFF10182B),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFFE9B0)
                      : const Color(0xFF263756),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 16,
                    color: selected
                        ? const Color(0xFF211407)
                        : const Color(0xFFFFD27A),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF211407)
                          : Colors.white.withOpacity(0.78),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String action,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A02F),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          action,
          style: TextStyle(
            color: Colors.white.withOpacity(0.48),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _NoResultView extends StatelessWidget {
  const _NoResultView({
    required this.onClear,
  });

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Color(0xFFFFD27A),
              size: 46,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không tìm thấy bảo vật',
              style: TextStyle(
                color: Color(0xFFFFE9B0),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Thử đổi từ khóa hoặc bỏ bộ lọc hiện tại.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.52),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onClear,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A02F),
                foregroundColor: const Color(0xFF211407),
              ),
              child: const Text(
                'Bỏ lọc',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopFilter {
  final String title;
  final IconData icon;

  const _ShopFilter(this.title, this.icon);
}