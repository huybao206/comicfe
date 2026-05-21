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
  final int? linkedGuildId;
  final String? guildName;

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
    this.linkedGuildId,
    this.guildName,
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
          'global')
          .toString(),
      description: map['description']?.toString(),
      isActive: _toBool(
        map['is_active'] ??
            map['isActive'] ??
            map['active'] ??
            map['status'] ??
            true,
      ),
      memberCount: _toInt(
        map['member_count'] ??
            map['memberCount'] ??
            map['members_count'] ??
            map['membersCount'] ??
            map['total_members'] ??
            map['totalMembers'] ??
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
            map['chat_message_count'] ??
            map['chatMessageCount'],
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
      linkedGuildId: _toNullableInt(
        map['linked_guild_id'] ?? map['linkedGuildId'] ?? map['guild_id'] ?? map['guildId'],
      ),
      guildName: (map['guild_name'] ?? map['guildName'])?.toString(),
    );
  }

  bool get isGuildRoom => roomType == 'guild';

  bool get isPublicRoom => roomType == 'global' || roomType == 'public' || roomType == 'world';

  String get displayName {
    if (roomName.trim().isNotEmpty) return roomName;
    if (roomCode.trim().isNotEmpty) return roomCode;
    return 'Phòng chat';
  }

  String get typeLabel {
    switch (roomType) {
      case 'guild':
        return guildName != null && guildName!.trim().isNotEmpty
            ? 'Bang phái · $guildName'
            : 'Bang phái';
      case 'vip':
        return 'VIP';
      case 'system':
        return 'Hệ thống';
      case 'global':
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

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return null;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
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
