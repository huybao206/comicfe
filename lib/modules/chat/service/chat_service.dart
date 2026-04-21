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

    List items = [];
    if (data is List) {
      items = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      items = (map['items'] ?? map['rooms'] ?? map['data'] ?? []) as List;
    }

    return items
        .map((e) => ChatRoom.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Message>> getMessages(int roomId) async {
    final data = await apiClient.get(ApiPaths.chatMessages(roomId));

    List items = [];
    if (data is List) {
      items = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      items = (map['items'] ?? map['messages'] ?? map['data'] ?? []) as List;
    }

    return items
        .map((e) => Message.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Message?> sendMessage({
    required int roomId,
    required String content,
  }) async {
    final data = await apiClient.post(
      ApiPaths.chatMessages(roomId),
      data: {
        'content': content,
      },
    );

    if (data is Map) {
      return Message.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }
}