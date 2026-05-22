class GuildJoinRequest {
  final int id;
  final int userId;
  final String requesterName;
  final String? avatarUrl;
  final String? message;
  final String status;
  final String? createdAt;

  GuildJoinRequest({
    required this.id,
    required this.userId,
    required this.requesterName,
    this.avatarUrl,
    this.message,
    required this.status,
    this.createdAt,
  });

  factory GuildJoinRequest.fromMap(Map<String, dynamic> map) {
    final requesterName = map['display_name'] ??
        map['displayName'] ??
        map['username'] ??
        map['requester_name'] ??
        map['requesterName'] ??
        map['name'] ??
        'Người dùng';

    return GuildJoinRequest(
      id: _toInt(map['id']),
      userId: _toInt(map['user_id'] ?? map['userId']),
      requesterName: requesterName.toString(),
      avatarUrl: map['avatar_url']?.toString() ?? map['avatarUrl']?.toString(),
      message: map['request_message']?.toString() ?? map['requestMessage']?.toString(),
      status: (map['request_status'] ?? map['requestStatus'] ?? map['status'] ?? 'pending').toString(),
      createdAt: map['created_at']?.toString() ?? map['createdAt']?.toString(),
    );
  }

  bool get isPending => status.toLowerCase().trim() == 'pending';

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString().trim();
    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }
}
