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

  bool isComicFollowed(int comicId) => followedComicIds.contains(comicId);

  Future<void> loadComics({String? keyword}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      comics = await comicService.getComics(keyword: keyword);
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

      if (isComicFollowed(comicId)) {
        followedComicIds.remove(comicId);
      } else {
        followedComicIds.add(comicId);
      }

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isFollowingSubmitting = false;
      notifyListeners();
    }
  }

  void clearDetail() {
    selectedComic = null;
    chapters = [];
    errorMessage = null;
    notifyListeners();
  }
}