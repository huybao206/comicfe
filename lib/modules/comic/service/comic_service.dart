import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/chapter.dart';
import '../model/comic.dart';

class ComicService {
  ComicService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<Comic>> getComics({
    int page = 1,
    int limit = 20,
    String? keyword,
  }) async {
    final data = await apiClient.get(
      ApiPaths.comics,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (keyword != null && keyword.trim().isNotEmpty)
          'keyword': keyword.trim(),
      },
    );

    final body = Map<String, dynamic>.from(data as Map);
    final items = body['items'] as List? ?? [];

    return items
        .map((e) => Comic.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Comic> getComicDetail(int comicId) async {
    final data = await apiClient.get(ApiPaths.comicDetail(comicId));
    return Comic.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<List<Chapter>> getChaptersByComic(int comicId) async {
    final data = await apiClient.get(ApiPaths.chaptersByComic(comicId));
    final items = data as List? ?? [];

    return items
        .map((e) => Chapter.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Chapter> getChapterDetail(int chapterId) async {
    final data = await apiClient.get(ApiPaths.chapterDetail(chapterId));
    return Chapter.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<ComicFollowResult> followComic(int comicId) async {
    final data = await apiClient.post(ApiPaths.followComic(comicId));
    return ComicFollowResult.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<ComicFollowResult> unfollowComic(int comicId) async {
    final data = await apiClient.delete(ApiPaths.followComic(comicId));
    return ComicFollowResult.fromMap(Map<String, dynamic>.from(data as Map));
  }
}

class ComicFollowResult {
  final int comicId;
  final bool isFollowing;
  final int totalFollows;

  const ComicFollowResult({
    required this.comicId,
    required this.isFollowing,
    required this.totalFollows,
  });

  factory ComicFollowResult.fromMap(Map<String, dynamic> map) {
    return ComicFollowResult(
      comicId: _toInt(map['comic_id'] ?? map['comicId']),
      isFollowing: _toBool(map['is_following'] ?? map['isFollowing']),
      totalFollows: _toInt(map['total_follows'] ?? map['totalFollows']),
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
}