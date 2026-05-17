import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
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
    } else if (response is Map && response['items'] is List) {
      rawList = response['items'];
    } else if (response is Map && response['notifications'] is List) {
      rawList = response['notifications'];
    }

    return rawList
        .whereType<Map>()
        .map(
          (e) => NotificationItem.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await apiClient.patch(
      ApiPaths.markNotificationRead(notificationId),
    );
  }
}