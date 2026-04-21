class GuildJoinRequest {
  final int id;
  final String requesterName;
  final String? status;
  final String? createdAt;

  GuildJoinRequest({
    required this.id,
    required this.requesterName,
    this.status,
    this.createdAt,
  });

  factory GuildJoinRequest.fromMap(Map<String, dynamic> map) {
    final requesterName = map['display_name'] ??
        map['username'] ??
        map['requester_name'] ??
        map['name'] ??
        'Người dùng';

    return GuildJoinRequest(
      id: int.tryParse('${map['id'] ?? 0}') ?? 0,
      requesterName: requesterName.toString(),
      status: map['status']?.toString(),
      createdAt: map['created_at']?.toString(),
    );
  }
}