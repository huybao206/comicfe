import 'package:flutter/material.dart';

class ShopEmptyView extends StatelessWidget {
  const ShopEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              color: Color(0xFFD0B06A),
              size: 44,
            ),
            SizedBox(height: 14),
            Text(
              'Tiên Các hiện chưa có bảo vật nào.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE6D4AC),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}