class ChatRoom {
  final int id;
  final String roomCode;
  final String roomName;
  final String roomType;
  final String? description;
  final bool isActive;
  final int memberCount;

  ChatRoom({
    required this.id,
    required this.roomCode,
    required this.roomName,
    required this.roomType,
    this.description,
    required this.isActive,
    required this.memberCount,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic value) => int.tryParse('$value') ?? 0;

    return ChatRoom(
      id: toInt(map['id']),
      roomCode: (map['room_code'] ?? map['code'] ?? '').toString(),
      roomName: (map['room_name'] ?? map['name'] ?? '').toString(),
      roomType: (map['room_type'] ?? map['type'] ?? 'public').toString(),
      description: map['description']?.toString(),
      isActive: '${map['is_active']}' == '1' || map['is_active'] == true,
      memberCount: toInt(map['member_count']),
    );
  }
}