import 'package:flutter/material.dart';

class NotificationEmptyView extends StatelessWidget {
  const NotificationEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: Color(0xFFD4B26A),
              size: 44,
            ),
            SizedBox(height: 14),
            Text(
              'Hiện chưa có thông báo nào.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE8D7B3),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}