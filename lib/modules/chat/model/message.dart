class Message {
  final int id;
  final int roomId;
  final int senderUserId;
  final String senderDisplayName;
  final String content;
  final String messageType;
  final String? createdAt;
  final bool isDeleted;

  Message({
    required this.id,
    required this.roomId,
    required this.senderUserId,
    required this.senderDisplayName,
    required this.content,
    required this.messageType,
    this.createdAt,
    required this.isDeleted,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic value) => int.tryParse('$value') ?? 0;

    return Message(
      id: toInt(map['id']),
      roomId: toInt(map['room_id'] ?? map['roomId']),
      senderUserId: toInt(map['sender_user_id'] ?? map['senderUserId']),
      senderDisplayName: (map['sender_display_name'] ??
          map['senderDisplayName'] ??
          map['display_name'] ??
          'User')
          .toString(),
      content: (map['content'] ?? '').toString(),
      messageType: (map['message_type'] ?? map['type'] ?? 'text').toString(),
      createdAt: map['created_at']?.toString(),
      isDeleted: '${map['is_deleted']}' == '1' || map['is_deleted'] == true,
    );
  }
}