import 'package:flutter/material.dart';

import '../model/chapter.dart';
import '../model/comic.dart';
import '../service/comic_service.dart';

class ComicProvider extends ChangeNotifier {
  ComicProvider({
    required this.comicService,
  });

  final ComicService comicService;

  bool isLoading = false;
  bool isFollowingSubmitting = false;
  bool isRankingLoading = false;
  String? errorMessage;
  String? rankingErrorMessage;

  List<Comic> comics = [];
  List<Comic> topComics = [];
  List<ComicGenre> genres = [];
  Comic? selectedComic;
  List<Chapter> chapters = [];

  String? selectedGenreSlug;
  String? currentKeyword;

  final Set<int> followedComicIds = {};

  bool isComicFollowed(int comicId) {
    if (selectedComic != null && selectedComic!.id == comicId) {
      return selectedComic!.isFollowing;
    }

    return followedComicIds.contains(comicId);
  }

  Future<void> loadComics({
    String? keyword,
    String? genreSlug,
  }) async {
    final normalizedKeyword = keyword?.trim() ?? '';
    final normalizedGenreSlug = genreSlug?.trim() ?? '';

    try {
      isLoading = true;
      errorMessage = null;
      currentKeyword = normalizedKeyword.isEmpty ? null : normalizedKeyword;
      selectedGenreSlug = normalizedGenreSlug.isEmpty ? null : normalizedGenreSlug;
      notifyListeners();

      comics = await comicService.getComics(
        keyword: currentKeyword,
        genreSlug: selectedGenreSlug,
        sort: selectedGenreSlug == null ? 'latest' : 'views',
      );

      _syncFollowedFromComics(comics);
      await _ensureGenresAndRankings();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGenres() async {
    try {
      genres = await comicService.getGenres();

      if (genres.isEmpty && comics.isNotEmpty) {
        genres = _deriveGenresFromComics(comics);
      }

      notifyListeners();
    } catch (_) {
      if (comics.isNotEmpty) {
        genres = _deriveGenresFromComics(comics);
        notifyListeners();
      }
    }
  }

  Future<void> loadComicRankings({
    String sort = 'hot',
    String? genreSlug,
  }) async {
    try {
      isRankingLoading = true;
      rankingErrorMessage = null;
      notifyListeners();

      topComics = await comicService.getComicRankings(
        limit: 30,
        sort: sort,
        genreSlug: genreSlug,
      );

      if (topComics.isEmpty && comics.isNotEmpty) {
        topComics = _sortComicsForRanking(comics).take(30).toList();
      }

      _syncFollowedFromComics(topComics);
    } catch (error) {
      rankingErrorMessage = error.toString().replaceFirst('Exception: ', '');

      if (comics.isNotEmpty) {
        topComics = _sortComicsForRanking(comics).take(30).toList();
      }
    } finally {
      isRankingLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadComicDetail(int comicId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      selectedComic = await comicService.getComicDetail(comicId);
      chapters = await comicService.getChaptersByComic(comicId);

      if (selectedComic?.isFollowing == true) {
        followedComicIds.add(comicId);
      } else {
        followedComicIds.remove(comicId);
      }
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFollowComic(int comicId) async {
    try {
      isFollowingSubmitting = true;
      errorMessage = null;
      notifyListeners();

      final currentlyFollowing = isComicFollowed(comicId);

      final result = currentlyFollowing
          ? await comicService.unfollowComic(comicId)
          : await comicService.followComic(comicId);

      if (result.isFollowing) {
        followedComicIds.add(comicId);
      } else {
        followedComicIds.remove(comicId);
      }

      _updateComicFollowState(
        comicId: comicId,
        isFollowing: result.isFollowing,
        totalFollows: result.totalFollows,
      );

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isFollowingSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _ensureGenresAndRankings() async {
    if (genres.isEmpty) {
      try {
        genres = await comicService.getGenres();
      } catch (_) {
        genres = _deriveGenresFromComics(comics);
      }
    }

    try {
      topComics = await comicService.getComicRankings(limit: 10, sort: 'hot');
    } catch (_) {
      topComics = _sortComicsForRanking(comics).take(10).toList();
    }

    if (genres.isEmpty) {
      genres = _deriveGenresFromComics(comics);
    }
  }

  void _syncFollowedFromComics(List<Comic> source) {
    followedComicIds
      ..clear()
      ..addAll(
        source.where((comic) => comic.isFollowing).map((comic) => comic.id),
      );
  }

  List<Comic> _sortComicsForRanking(List<Comic> source) {
    final sorted = [...source];

    sorted.sort((a, b) {
      final scoreA = a.totalViews + a.totalFollows * 10;
      final scoreB = b.totalViews + b.totalFollows * 10;
      final byScore = scoreB.compareTo(scoreA);
      if (byScore != 0) return byScore;

      final byChapter = b.totalChapters.compareTo(a.totalChapters);
      if (byChapter != 0) return byChapter;

      return b.id.compareTo(a.id);
    });

    return sorted;
  }

  List<ComicGenre> _deriveGenresFromComics(List<Comic> source) {
    final counts = <String, int>{};

    for (final comic in source) {
      final raw = comic.genres ?? '';
      for (final item in raw.split(',')) {
        final name = item.trim();
        if (name.isEmpty) continue;
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }

    var index = 0;
    final result = counts.entries.map((entry) {
      index += 1;
      return ComicGenre(
        id: index,
        name: entry.key,
        slug: _slugify(entry.key),
        comicCount: entry.value,
      );
    }).toList();

    result.sort((a, b) {
      final byCount = b.comicCount.compareTo(a.comicCount);
      if (byCount != 0) return byCount;
      return a.name.compareTo(b.name);
    });

    return result;
  }

  String _slugify(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll('đ', 'd')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  void _updateComicFollowState({
    required int comicId,
    required bool isFollowing,
    required int totalFollows,
  }) {
    if (selectedComic != null && selectedComic!.id == comicId) {
      selectedComic = selectedComic!.copyWith(
        isFollowing: isFollowing,
        totalFollows: totalFollows,
      );
    }

    final index = comics.indexWhere((comic) => comic.id == comicId);

    if (index != -1) {
      comics[index] = comics[index].copyWith(
        isFollowing: isFollowing,
        totalFollows: totalFollows,
      );
    }

    final rankingIndex = topComics.indexWhere((comic) => comic.id == comicId);

    if (rankingIndex != -1) {
      topComics[rankingIndex] = topComics[rankingIndex].copyWith(
        isFollowing: isFollowing,
        totalFollows: totalFollows,
      );
    }
  }

  void clearDetail() {
    selectedComic = null;
    chapters = [];
    errorMessage = null;
    notifyListeners();
  }
}
