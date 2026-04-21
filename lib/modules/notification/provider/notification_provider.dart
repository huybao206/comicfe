import 'package:flutter/material.dart';

import '../model/notification_item.dart';
import '../service/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService notificationService;

  NotificationProvider({required this.notificationService});

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  List<NotificationItem> items = [];

  int get unreadCount => items.where((e) => !e.isRead).length;

  Future<void> loadNotifications() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      items = await notificationService.getMyNotifications();
    } catch (e) {
      errorMessage = _err(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> readNotification(int id) async {
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    if (items[index].isRead) return true;

    final old = items[index];

    try {
      isSubmitting = true;

      items[index] = NotificationItem(
        id: old.id,
        title: old.title,
        content: old.content,
        isRead: true,
        typeCode: old.typeCode,
        createdAt: old.createdAt,
      );
      notifyListeners();

      await notificationService.markAsRead(id);
      return true;
    } catch (e) {
      items[index] = old;
      errorMessage = _err(e);
      notifyListeners();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> readAllUnread() async {
    final unreadIds = items.where((e) => !e.isRead).map((e) => e.id).toList();

    for (final id in unreadIds) {
      await readNotification(id);
    }
  }

  String _err(dynamic e) => e.toString().replaceFirst('Exception: ', '');
}