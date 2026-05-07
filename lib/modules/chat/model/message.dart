import '../../../core/config/app_env.dart';

class Message {
  final int id;
  final int roomId;
  final int senderUserId;
  final String senderDisplayName;
  final String? senderUsername;
  final String? senderAvatarUrl;
  final String content;
  final String messageType;
  final DateTime? createdAt;
  final bool isDeleted;
  final int? replyToMessageId;

  const Message({
    required this.id,
    required this.roomId,
    required this.senderUserId,
    required this.senderDisplayName,
    required this.senderUsername,
    required this.senderAvatarUrl,
    required this.content,
    required this.messageType,
    required this.createdAt,
    required this.isDeleted,
    required this.replyToMessageId,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    final userMap = map['user'] is Map
        ? Map<String, dynamic>.from(map['user'] as Map)
        : <String, dynamic>{};

    return Message(
      id: _toInt(map['id']),
      roomId: _toInt(map['room_id'] ?? map['roomId']),
      senderUserId: _toInt(
        map['user_id'] ??
            map['userId'] ??
            map['sender_user_id'] ??
            map['senderUserId'] ??
            userMap['id'],
      ),
      senderDisplayName: (map['display_name'] ??
          map['displayName'] ??
          map['sender_display_name'] ??
          map['senderDisplayName'] ??
          userMap['display_name'] ??
          userMap['displayName'] ??
          userMap['username'] ??
          'Đạo hữu')
          .toString(),
      senderUsername: (map['username'] ?? userMap['username'])?.toString(),
      senderAvatarUrl: _buildFullImageUrl(
        (map['avatar_url'] ??
            map['avatarUrl'] ??
            userMap['avatar_url'] ??
            userMap['avatarUrl'])
            ?.toString(),
      ),
      content: (map['content'] ?? map['message'] ?? '').toString(),
      messageType:
      (map['message_type'] ?? map['messageType'] ?? map['type'] ?? 'text')
          .toString(),
      createdAt: _toNullableDateTime(
        map['sent_at'] ??
            map['sentAt'] ??
            map['created_at'] ??
            map['createdAt'],
      ),
      isDeleted: _toBool(map['is_deleted'] ?? map['isDeleted']),
      replyToMessageId: _toNullableInt(
        map['reply_to_message_id'] ?? map['replyToMessageId'],
      ),
    );
  }

  String get timeText {
    if (createdAt == null) return '';

    final value = createdAt!;
    final now = DateTime.now();
    final diff = now.difference(value);

    if (diff.inMinutes < 1) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day/$month $hour:$minute';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;

    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;

    return DateTime.tryParse(text);
  }

  static String? _buildFullImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final value = raw.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final normalized = value.replaceAll('\\', '/');
    final mediaBaseUrl = AppEnv.baseUrl.replaceFirst('/api', '');

    if (normalized.startsWith('/')) {
      return '$mediaBaseUrl$normalized';
    }

    return '$mediaBaseUrl/$normalized';
  }
}