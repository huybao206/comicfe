import 'package:flutter/material.dart';

import '../model/shop_item.dart';

Future<int?> showBuyItemDialog(BuildContext context, ShopItem item) async {
  final quantityController = TextEditingController(text: '1');

  final quantity = await showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF15110C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF8B6A2B), width: 1.2),
        ),
        title: Text(
          'Mua ${item.itemName}',
          style: const TextStyle(
            color: Color(0xFFF6E7BE),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Số lượng',
            labelStyle: const TextStyle(color: Color(0xFFD8C08A)),
            filled: true,
            fillColor: const Color(0xFF21170F),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6E5423)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE0B85C)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
              Navigator.of(dialogContext).pop(parsed < 1 ? 1 : parsed);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC7962F),
              foregroundColor: const Color(0xFF24170B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Mua',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );
    },
  );

  quantityController.dispose();
  return quantity;
}