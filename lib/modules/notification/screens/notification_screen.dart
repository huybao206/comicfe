import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: const Color(0xFF0D0A07),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadNotifications(),
        child: Builder(
          builder: (_) {
            if (provider.isLoading && provider.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.items.isEmpty) {
              return const Center(
                child: Text(
                  'Không có thông báo',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];

                return ListTile(
                  onTap: () {
                    if (!item.isRead) {
                      context.read<NotificationProvider>().readNotification(item.id);
                    }
                  },
                  leading: Icon(
                    item.isRead ? Icons.mark_email_read : Icons.notifications,
                    color: item.isRead ? Colors.grey : Colors.amber,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                      item.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    item.content,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    _formatTime(item.createdAt),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}