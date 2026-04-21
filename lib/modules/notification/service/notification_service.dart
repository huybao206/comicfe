import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_paths.dart';
import '../model/notification_item.dart';

class NotificationService {
  final ApiClient apiClient;

  NotificationService({required this.apiClient});

  Future<List<NotificationItem>> getMyNotifications() async {
    final response = await apiClient.get(ApiPaths.myNotifications);

    List rawList = [];

    if (response is List) {
      rawList = response;
    } else if (response is Map && response['data'] is List) {
      rawList = response['data'];
    }

    return rawList
        .map((e) => NotificationItem.fromMap(
      Map<String, dynamic>.from(e),
    ))
        .toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await apiClient.post(
      ApiPaths.markNotificationRead(notificationId),
    );
  }
}