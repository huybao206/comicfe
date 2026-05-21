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
    // Lớp chặn thêm ở FE để dù BE còn dữ liệu cũ hoặc đang cache,
    // user cũng không thấy chat bang khác.
    final myGuildId = await _getMyActiveGuildId();
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
        .where((room) {
      if (!room.isGuildRoom) return true;
      if (myGuildId == null) return false;
      return room.linkedGuildId == myGuildId;
    })
        .toList();
  }

  Future<int?> _getMyActiveGuildId() async {
    try {
      final data = await apiClient.get(ApiPaths.myGuild);
      return _extractGuildId(data);
    } catch (_) {
      // Nếu user chưa vào bang hoặc API trả 404/204 thì coi như không có bang.
      // Khi không có bang, FE sẽ ẩn toàn bộ room room_type='guild'.
      return null;
    }
  }

  int? _extractGuildId(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final directId = _toNullableInt(
        map['guild_id'] ?? map['guildId'] ?? map['id'],
      );
      if (directId != null) return directId;

      final guildValue = map['guild'];
      if (guildValue is Map) {
        final guild = Map<String, dynamic>.from(guildValue);
        final id = _toNullableInt(guild['id'] ?? guild['guild_id'] ?? guild['guildId']);
        if (id != null) return id;
      }

      final dataValue = map['data'];
      if (dataValue is Map) {
        return _extractGuildId(Map<String, dynamic>.from(dataValue));
      }
    }

    return null;
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

  int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return null;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }
}
