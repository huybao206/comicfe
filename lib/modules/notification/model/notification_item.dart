
class NotificationItem {
  final int id;
  final String title;
  final String content;
  final bool isRead;
  final String typeCode;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    required this.typeCode,
    required this.createdAt,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: _toInt(map['id']),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),

      isRead: _toBool(map['isRead'] ?? map['is_read']),

      typeCode: (map['typeCode'] ?? map['type_code'] ?? map['type'] ?? '')
          .toString(),

      createdAt: _toDateTime(map['createdAt'] ?? map['created_at']),
    );
  }

  NotificationItem copyWith({
    int? id,
    String? title,
    String? content,
    bool? isRead,
    String? typeCode,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      typeCode: typeCode ?? this.typeCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;

    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;

    final text = value?.toString();
    if (text == null || text.trim().isEmpty) {
      return DateTime.now();
    }

    return DateTime.tryParse(text) ?? DateTime.now();
  }
}