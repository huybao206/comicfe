import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/chat_room.dart';
import '../model/message.dart';

class ChatService {
  ChatService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<ChatRoom>> getRooms() async {
    final data = await apiClient.get(ApiPaths.chatRooms);

    final items = _extractList(
      data,
      keys: const [
        'items',
        'rooms',
        'data',
        'chatRooms',
        'chat_rooms',
        'results',
        'rows',
      ],
    );

    return items
        .whereType<Map>()
        .map(
          (e) => ChatRoom.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .where((room) => room.isActive)
        .toList();
  }

  Future<List<Message>> getMessages(
      int roomId, {
        int limit = 50,
      }) async {
    final data = await apiClient.get(
      ApiPaths.chatMessages(roomId),
      queryParameters: {
        'limit': limit,
      },
    );

    final items = _extractList(
      data,
      keys: const [
        'messages',
        'items',
        'data',
        'rows',
        'results',
        'chatMessages',
        'chat_messages',
      ],
    );

    final messages = items
        .whereType<Map>()
        .map(
          (e) => Message.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .where((message) => !message.isDeleted)
        .toList();

    messages.sort((a, b) {
      final aTime = a.createdAt;
      final bTime = b.createdAt;

      if (aTime == null && bTime == null) return a.id.compareTo(b.id);
      if (aTime == null) return -1;
      if (bTime == null) return 1;

      return aTime.compareTo(bTime);
    });

    return messages;
  }

  Future<void> sendMessage({
    required int roomId,
    required String content,
  }) async {
    await apiClient.post(
      ApiPaths.chatMessages(roomId),
      data: {
        'content': content.trim(),
        'messageType': 'text',
        'message_type': 'text',
      },
    );
  }

  List _extractList(
      dynamic data, {
        required List<String> keys,
      }) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      for (final key in keys) {
        final value = map[key];

        if (value is List) {
          return value;
        }

        if (value is Map) {
          final nested = Map<String, dynamic>.from(value);

          if (nested['items'] is List) return nested['items'] as List;
          if (nested['rows'] is List) return nested['rows'] as List;
          if (nested['results'] is List) return nested['results'] as List;
          if (nested['messages'] is List) return nested['messages'] as List;
          if (nested['rooms'] is List) return nested['rooms'] as List;
        }
      }
    }

    return const [];
  }
}