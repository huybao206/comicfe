import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/shop_item.dart';

typedef BuyItemSubmit = Future<String?> Function(int quantity);

Future<int?> showBuyItemDialog(
    BuildContext context,
    ShopItem item, {
      required BuyItemSubmit onSubmit,
    }) async {
  return showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _BuyItemDialogContent(
        item: item,
        onSubmit: onSubmit,
      );
    },
  );
}

class _BuyItemDialogContent extends StatefulWidget {
  const _BuyItemDialogContent({
    required this.item,
    required this.onSubmit,
  });

  final ShopItem item;
  final BuyItemSubmit onSubmit;

  @override
  State<_BuyItemDialogContent> createState() => _BuyItemDialogContentState();
}

class _BuyItemDialogContentState extends State<_BuyItemDialogContent>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _quantityController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _quantityController = TextEditingController(text: '1');
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 430),
    );

    _shakeAnimation = TweenSequence<double>(
      [
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: -14),
          weight: 1,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -14, end: 14),
          weight: 2,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 14, end: -10),
          weight: 2,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -10, end: 10),
          weight: 2,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 10, end: -6),
          weight: 1,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -6, end: 0),
          weight: 1,
        ),
      ],
    ).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _shake([String? message]) async {
    if (message != null && mounted) {
      setState(() {
        _errorMessage = message;
      });
    }

    HapticFeedback.heavyImpact();
    await _shakeController.forward(from: 0);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (quantity < 1) {
      await _shake('Số lượng mua phải lớn hơn 0');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final error = await widget.onSubmit(quantity);

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(quantity);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = _friendlyError(error);
    });

    await _shake();
  }

  String _friendlyError(String error) {
    final text = error.trim();
    final lower = text.toLowerCase();

    if (lower.contains('không đủ vàng') ||
        lower.contains('khong du vang') ||
        lower.contains('không đủ ngọc') ||
        lower.contains('khong du ngoc') ||
        lower.contains('không đủ premium') ||
        lower.contains('khong du premium') ||
        lower.contains('không đủ tiền') ||
        lower.contains('khong du tien')) {
      return text.startsWith('Không đủ tiền')
          ? text
          : 'Không đủ tiền để mua vật phẩm';
    }

    return text.isEmpty ? 'Không mua được vật phẩm' : text;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: AlertDialog(
        backgroundColor: const Color(0xFF15110C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _errorMessage == null
                ? const Color(0xFF8B6A2B)
                : const Color(0xFFFF6B6B),
            width: 1.35,
          ),
        ),
        title: Text(
          'Mua ${widget.item.itemName}',
          style: const TextStyle(
            color: Color(0xFFF6E7BE),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _quantityController,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Số lượng',
                labelStyle: const TextStyle(color: Color(0xFFD8C08A)),
                filled: true,
                fillColor: const Color(0xFF21170F),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _errorMessage == null
                        ? const Color(0xFF6E5423)
                        : const Color(0xFFFF6B6B),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE0B85C)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF6E5423)),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _errorMessage == null
                  ? const SizedBox(height: 12)
                  : Container(
                key: ValueKey(_errorMessage),
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A1414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withOpacity(0.55),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFFF8A8A),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFFD1D1),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed:
            _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC7962F),
              disabledBackgroundColor: const Color(0xFF5A4A25),
              foregroundColor: const Color(0xFF24170B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF24170B),
              ),
            )
                : const Text(
              'Mua',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
