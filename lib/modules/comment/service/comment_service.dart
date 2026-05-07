import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/comment_item.dart';

class CommentService {
  CommentService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<CommentItem>> getComicComments({
    required int comicId,
    int page = 1,
    int limit = 20,
    String sort = 'newest',
  }) async {
    final data = await apiClient.get(
      ApiPaths.comicComments(comicId),
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort': sort,
      },
    );

    final body = Map<String, dynamic>.from(data as Map);
    final items = body['items'] as List? ?? [];

    return items
        .whereType<Map>()
        .map(
          (e) => CommentItem.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<CommentItem> createComicComment({
    required int comicId,
    required String content,
  }) async {
    final data = await apiClient.post(
      ApiPaths.comments,
      data: {
        'comic_id': comicId,
        'content': content.trim(),
      },
    );

    return CommentItem.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<CommentItem> replyComicComment({
    required int comicId,
    required int parentCommentId,
    required String content,
  }) async {
    final data = await apiClient.post(
      ApiPaths.comments,
      data: {
        'comic_id': comicId,
        'parent_comment_id': parentCommentId,
        'content': content.trim(),
      },
    );

    return CommentItem.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<List<CommentItem>> getChapterComments({
    required int chapterId,
    int page = 1,
    int limit = 20,
    String sort = 'newest',
  }) async {
    final data = await apiClient.get(
      ApiPaths.chapterComments(chapterId),
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort': sort,
      },
    );

    final body = Map<String, dynamic>.from(data as Map);
    final items = body['items'] as List? ?? [];

    return items
        .whereType<Map>()
        .map(
          (e) => CommentItem.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<CommentItem> createChapterComment({
    required int chapterId,
    required String content,
  }) async {
    final data = await apiClient.post(
      ApiPaths.comments,
      data: {
        'chapter_id': chapterId,
        'content': content.trim(),
      },
    );

    return CommentItem.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }
}