import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/profile_utility_models.dart';
import '../provider/user_provider.dart';
import '../service/user_service.dart';
import 'package:my_book/core/widgets/app_top_toast.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<InventoryData> _future;
  bool _isUsingItem = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<InventoryData> _load() {
    return context.read<UserService>().getMyInventory();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _useItem(InventoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF17110C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF735624)),
          ),
          title: const Text(
            'Dùng vật phẩm',
            style: TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Bạn muốn dùng 1 ${item.name}?',
            style: const TextStyle(color: Color(0xFFE8D7B3), height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC7962F),
                foregroundColor: const Color(0xFF24170B),
              ),
              child: const Text('Dùng ngay', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() => _isUsingItem = true);

    try {
      final result = await context.read<UserService>().useInventoryItem(
        itemId: item.itemId,
        quantity: 1,
      );

      if (!mounted) return;
      AppTopToast.fromSnackBar(context,
        SnackBar(
          backgroundColor: const Color(0xFF2F6B3B),
          content: Text(result.summaryText),
        ),
      );

      context.read<UserProvider>().loadMyProfile();
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      AppTopToast.fromSnackBar(context,
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUsingItem = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        title: const Text('Túi đồ'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D0A07),
        foregroundColor: const Color(0xFFF6E7BE),
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: _refresh,
        child: FutureBuilder<InventoryData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFC7962F)),
              );
            }

            if (snapshot.hasError) {
              return _MessageView(
                icon: Icons.error_outline_rounded,
                title: 'Không tải được túi đồ',
                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const _MessageView(
                icon: Icons.inventory_2_outlined,
                title: 'Không có dữ liệu',
                message: 'Túi đồ chưa có dữ liệu để hiển thị.',
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _InventorySummaryCard(summary: data.summary),
                const SizedBox(height: 14),
                const Text(
                  'Vật phẩm sở hữu',
                  style: TextStyle(
                    color: Color(0xFFF6E7BE),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                if (data.items.isEmpty)
                  const _MessageBox(
                    icon: Icons.inventory_2_outlined,
                    title: 'Túi đồ đang trống',
                    message: 'Mua vật phẩm trong Shop hoặc nhận thưởng nhiệm vụ để vật phẩm xuất hiện ở đây.',
                  )
                else
                  ...data.items.map(
                        (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InventoryItemCard(
                        item: item,
                        isBusy: _isUsingItem,
                        onUse: item.usableInstantly && item.quantity > 0
                            ? () => _useItem(item)
                            : null,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InventorySummaryCard extends StatelessWidget {
  const _InventorySummaryCard({required this.summary});

  final InventorySummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1E12), Color(0xFF17110C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tài sản tu luyện',
            style: TextStyle(
              color: Color(0xFFF6E7BE),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SummaryTile(label: 'Vật phẩm', value: '${summary.totalQuantity}', icon: Icons.inventory_2_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile(label: 'Vàng', value: '${summary.goldBalance}', icon: Icons.monetization_on_outlined)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SummaryTile(label: 'Ngọc', value: '${summary.premiumCurrency}', icon: Icons.diamond_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryTile(label: 'Linh thạch', value: '${summary.spiritStones}', icon: Icons.auto_awesome_rounded)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5E451D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE0B85C), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFFB89E70), fontSize: 11.5)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({
    required this.item,
    required this.isBusy,
    required this.onUse,
  });

  final InventoryItem item;
  final bool isBusy;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF23180F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF5E451D)),
            ),
            child: item.iconUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.iconUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, color: Color(0xFFE0B85C)),
              ),
            )
                : const Icon(Icons.inventory_2_outlined, color: Color(0xFFE0B85C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF6E7BE),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(color: Color(0xFFE0B85C), fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description?.trim().isNotEmpty == true
                      ? item.description!.trim()
                      : 'Chưa có mô tả vật phẩm.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFCCB991), height: 1.35, fontSize: 12.5),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Badge(text: item.rarity.toUpperCase()),
                    if (item.itemTypeName != null && item.itemTypeName!.trim().isNotEmpty)
                      _Badge(text: item.itemTypeName!),
                    if (item.expBonus > 0) _Badge(text: '+${item.expBonus} EXP'),
                    if (item.powerBonus > 0) _Badge(text: '+${item.powerBonus} lực chiến'),
                  ],
                ),
                if (onUse != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: isBusy ? null : onUse,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC7962F),
                        foregroundColor: const Color(0xFF24170B),
                        disabledBackgroundColor: const Color(0xFF5D4C2D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: isBusy
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text('Dùng', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF23180F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF5E451D)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFD6BE8A), fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF17110C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF735624)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFE0B85C), size: 34),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFCCB991), height: 1.45)),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 120, 28, 24),
      children: [
        Icon(icon, size: 54, color: const Color(0xFFE0B85C)),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFF6E7BE), fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFCCB991), height: 1.45),
        ),
      ],
    );
  }
}
