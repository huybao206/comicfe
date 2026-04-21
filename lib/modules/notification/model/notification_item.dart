class NotificationItem {
  final int id;
  final String title;
  final String content;
  final bool isRead;
  final String typeCode;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    required this.typeCode,
    required this.createdAt,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      isRead: map['isRead'] ?? false,
      typeCode: map['typeCode'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}