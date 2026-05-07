class ChatRoom {
  final int id;
  final String roomCode;
  final String roomName;
  final String roomType;
  final String? description;
  final bool isActive;
  final int memberCount;
  final int messageCount;
  final DateTime? lastActivityAt;

  const ChatRoom({
    required this.id,
    required this.roomCode,
    required this.roomName,
    required this.roomType,
    required this.description,
    required this.isActive,
    required this.memberCount,
    required this.messageCount,
    required this.lastActivityAt,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: _toInt(map['id'] ?? map['room_id'] ?? map['roomId']),
      roomCode: (map['room_code'] ??
          map['roomCode'] ??
          map['code'] ??
          map['slug'] ??
          '')
          .toString(),
      roomName: (map['room_name'] ??
          map['roomName'] ??
          map['name'] ??
          map['title'] ??
          'Phòng chat')
          .toString(),
      roomType: (map['room_type'] ??
          map['roomType'] ??
          map['type'] ??
          map['category'] ??
          'public')
          .toString(),
      description: map['description']?.toString(),
      isActive: _toBool(
        map['is_active'] ??
            map['isActive'] ??
            map['active'] ??
            map['status'] ??
            true,
      ),

      // Đọc nhiều kiểu tên field vì admin/BE có thể đặt khác nhau.
      memberCount: _toInt(
        map['member_count'] ??
            map['memberCount'] ??
            map['members_count'] ??
            map['membersCount'] ??
            map['total_members'] ??
            map['totalMembers'] ??
            map['total_member'] ??
            map['totalMember'] ??
            map['user_count'] ??
            map['userCount'] ??
            map['participants_count'] ??
            map['participantsCount'] ??
            map['active_member_count'] ??
            map['activeMemberCount'],
      ),

      messageCount: _toInt(
        map['message_count'] ??
            map['messageCount'] ??
            map['messages_count'] ??
            map['messagesCount'] ??
            map['total_messages'] ??
            map['totalMessages'] ??
            map['total_message'] ??
            map['totalMessage'] ??
            map['chat_message_count'] ??
            map['chatMessageCount'] ??
            map['msg_count'] ??
            map['msgCount'],
      ),

      lastActivityAt: _toNullableDateTime(
        map['last_activity_at'] ??
            map['lastActivityAt'] ??
            map['last_message_at'] ??
            map['lastMessageAt'] ??
            map['latest_message_at'] ??
            map['latestMessageAt'] ??
            map['updated_at'] ??
            map['updatedAt'],
      ),
    );
  }

  String get displayName {
    if (roomName.trim().isNotEmpty) return roomName;
    if (roomCode.trim().isNotEmpty) return roomCode;
    return 'Phòng chat';
  }

  String get typeLabel {
    switch (roomType) {
      case 'guild':
        return 'Bang phái';
      case 'vip':
        return 'VIP';
      case 'system':
        return 'Hệ thống';
      case 'public':
      case 'world':
        return 'Công cộng';
      default:
        return 'Phòng chat';
    }
  }

  String get lastActivityText {
    if (lastActivityAt == null) return '-';

    final value = lastActivityAt!;
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day/$month $hour:$minute';
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;

    final text = value?.toString().toLowerCase().trim();

    if (text == null || text.isEmpty) return true;

    return text == 'true' ||
        text == '1' ||
        text == 'yes' ||
        text == 'active' ||
        text == 'hoạt động';
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return null;

    return DateTime.tryParse(text);
  }
}