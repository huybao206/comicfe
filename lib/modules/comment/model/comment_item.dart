import '../../../core/config/app_env.dart';

class CommentItem {
  final int id;
  final int userId;
  final int? comicId;
  final int? chapterId;
  final int? parentCommentId;
  final String content;
  final String status;
  final int likeCount;
  final int reportCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String username;
  final String displayName;
  final String? avatarUrl;

  final List<CommentItem> replies;

  const CommentItem({
    required this.id,
    required this.userId,
    required this.comicId,
    required this.chapterId,
    required this.parentCommentId,
    required this.content,
    required this.status,
    required this.likeCount,
    required this.reportCount,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.replies,
  });

  factory CommentItem.fromMap(Map<String, dynamic> map) {
    final userMap = map['user'] is Map
        ? Map<String, dynamic>.from(map['user'] as Map)
        : <String, dynamic>{};

    final rawReplies = map['replies'];

    return CommentItem(
      id: _toInt(map['id']),
      userId: _toInt(map['user_id'] ?? map['userId'] ?? userMap['id']),
      comicId: _toNullableInt(map['comic_id'] ?? map['comicId']),
      chapterId: _toNullableInt(map['chapter_id'] ?? map['chapterId']),
      parentCommentId: _toNullableInt(
        map['parent_comment_id'] ?? map['parentCommentId'],
      ),
      content: (map['content'] ?? '').toString(),
      status: (map['comment_status'] ?? map['commentStatus'] ?? 'visible')
          .toString(),
      likeCount: _toInt(map['like_count'] ?? map['likeCount']),
      reportCount: _toInt(map['report_count'] ?? map['reportCount']),
      createdAt: _toDateTime(map['created_at'] ?? map['createdAt']),
      updatedAt: _toNullableDateTime(map['updated_at'] ?? map['updatedAt']),
      username: (userMap['username'] ?? map['username'] ?? 'user').toString(),
      displayName: (userMap['display_name'] ??
          userMap['displayName'] ??
          map['display_name'] ??
          map['displayName'] ??
          map['username'] ??
          'Người dùng')
          .toString(),
      avatarUrl: _buildFullImageUrl(
        (userMap['avatar_url'] ??
            userMap['avatarUrl'] ??
            map['avatar_url'] ??
            map['avatarUrl'])
            ?.toString(),
      ),
      replies: rawReplies is List
          ? rawReplies
          .whereType<Map>()
          .map(
            (e) => CommentItem.fromMap(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : const [],
    );
  }

  CommentItem copyWith({
    int? id,
    int? userId,
    int? comicId,
    int? chapterId,
    int? parentCommentId,
    String? content,
    String? status,
    int? likeCount,
    int? reportCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? username,
    String? displayName,
    String? avatarUrl,
    List<CommentItem>? replies,
  }) {
    return CommentItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      comicId: comicId ?? this.comicId,
      chapterId: chapterId ?? this.chapterId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      status: status ?? this.status,
      likeCount: likeCount ?? this.likeCount,
      reportCount: reportCount ?? this.reportCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      replies: replies ?? this.replies,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;

    return int.tryParse(text);
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;

    final text = value?.toString();
    if (text == null || text.trim().isEmpty) {
      return DateTime.now();
    }

    return DateTime.tryParse(text) ?? DateTime.now();
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