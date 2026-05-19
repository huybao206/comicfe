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
    int limit = 100,
    String? keyword,
    String? genreSlug,
    String? sort,
  }) async {
    final data = await apiClient.get(
      ApiPaths.comics,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (keyword != null && keyword.trim().isNotEmpty)
          'keyword': keyword.trim(),
        if (genreSlug != null && genreSlug.trim().isNotEmpty)
          'genreSlug': genreSlug.trim(),
        if (sort != null && sort.trim().isNotEmpty)
          'sort': sort.trim(),
      },
    );

    final items = _extractList(data);

    return items
        .whereType<Map>()
        .map(
          (e) => Comic.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .where((comic) => comic.id > 0)
        .toList();
  }


  Future<List<ComicGenre>> getGenres() async {
    final data = await apiClient.get(ApiPaths.comicGenres);
    final items = _extractList(data);

    return items
        .whereType<Map>()
        .map(
          (e) => ComicGenre.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .where((genre) => genre.id > 0 && genre.name.trim().isNotEmpty)
        .toList();
  }

  Future<List<Comic>> getComicRankings({
    int limit = 20,
    String sort = 'hot',
    String? genreSlug,
  }) async {
    final data = await apiClient.get(
      ApiPaths.comicRankings,
      queryParameters: {
        'limit': limit,
        'sort': sort,
        if (genreSlug != null && genreSlug.trim().isNotEmpty)
          'genreSlug': genreSlug.trim(),
      },
    );

    final items = _extractList(data);

    return items
        .whereType<Map>()
        .map(
          (e) => Comic.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .where((comic) => comic.id > 0)
        .toList();
  }

  Future<Comic> getComicDetail(int comicId) async {
    final data = await apiClient.get(ApiPaths.comicDetail(comicId));

    return Comic.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<void> saveReadingProgress({
    required int chapterId,
    int lastPageNumber = 1,
    double? progressPercent,
  }) async {
    await apiClient.post(
      ApiPaths.saveChapterProgress(chapterId),
      data: {
        'last_page_number': lastPageNumber,
        if (progressPercent != null) 'progress_percent': progressPercent,
      },
    );
  }

  Future<List<Chapter>> getChaptersByComic(int comicId) async {
    final data = await apiClient.get(ApiPaths.chaptersByComic(comicId));

    final items = _extractList(data);

    return items
        .whereType<Map>()
        .map(
          (e) => Chapter.fromMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<Chapter> getChapterDetail(int chapterId) async {
    final data = await apiClient.get(ApiPaths.chapterDetail(chapterId));

    return Chapter.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<ComicFollowResult> followComic(int comicId) async {
    final data = await apiClient.post(ApiPaths.followComic(comicId));

    return ComicFollowResult.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<ComicFollowResult> unfollowComic(int comicId) async {
    final data = await apiClient.delete(ApiPaths.followComic(comicId));

    return ComicFollowResult.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }

  List _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['items'] is List) return map['items'] as List;
      if (map['data'] is List) return map['data'] as List;
      if (map['rows'] is List) return map['rows'] as List;
      if (map['results'] is List) return map['results'] as List;
      if (map['comics'] is List) return map['comics'] as List;
      if (map['genres'] is List) return map['genres'] as List;

      if (map['data'] is Map) {
        final nested = Map<String, dynamic>.from(map['data'] as Map);

        if (nested['items'] is List) return nested['items'] as List;
        if (nested['rows'] is List) return nested['rows'] as List;
        if (nested['results'] is List) return nested['results'] as List;
        if (nested['comics'] is List) return nested['comics'] as List;
        if (nested['genres'] is List) return nested['genres'] as List;
      }
    }

    return const [];
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
    if (value == null) return 0;

    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '-') return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;

    final text = value?.toString().toLowerCase().trim();

    return text == 'true' || text == '1' || text == 'yes';
  }
}