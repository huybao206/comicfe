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
  String? errorMessage;

  List<Comic> comics = [];
  Comic? selectedComic;
  List<Chapter> chapters = [];

  final Set<int> followedComicIds = {};

  bool isComicFollowed(int comicId) {
    if (selectedComic != null && selectedComic!.id == comicId) {
      return selectedComic!.isFollowing;
    }

    return followedComicIds.contains(comicId);
  }

  Future<void> loadComics({String? keyword}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      comics = await comicService.getComics(keyword: keyword);

      followedComicIds
        ..clear()
        ..addAll(
          comics.where((comic) => comic.isFollowing).map((comic) => comic.id),
        );
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
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
  }

  void clearDetail() {
    selectedComic = null;
    chapters = [];
    errorMessage = null;
    notifyListeners();
  }
}