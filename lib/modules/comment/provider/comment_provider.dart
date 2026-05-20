import 'package:flutter/material.dart';

import '../model/comment_item.dart';
import '../service/comment_service.dart';

class CommentProvider extends ChangeNotifier {
  CommentProvider({
    required this.commentService,
  });

  final CommentService commentService;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  final Map<int, List<CommentItem>> _comicComments = {};
  final Map<int, List<CommentItem>> _chapterComments = {};

  List<CommentItem> commentsOfComic(int comicId) {
    return _comicComments[comicId] ?? const [];
  }

  List<CommentItem> commentsOfChapter(int chapterId) {
    return _chapterComments[chapterId] ?? const [];
  }

  Future<void> loadComicComments(int comicId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final comments = await commentService.getComicComments(
        comicId: comicId,
        page: 1,
        limit: 30,
        sort: 'newest',
      );

      _comicComments[comicId] = comments;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChapterComments(int chapterId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final comments = await commentService.getChapterComments(
        chapterId: chapterId,
        page: 1,
        limit: 50,
        sort: 'newest',
      );

      _chapterComments[chapterId] = comments;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createComicComment({
    required int comicId,
    required String content,
  }) async {
    final cleanContent = content.trim();

    if (cleanContent.isEmpty) {
      errorMessage = 'Vui lòng nhập nội dung bình luận';
      notifyListeners();
      return false;
    }

    if (cleanContent.length > 1000) {
      errorMessage = 'Bình luận không được vượt quá 1000 ký tự';
      notifyListeners();
      return false;
    }

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      final created = await commentService.createComicComment(
        comicId: comicId,
        content: cleanContent,
      );

      final oldList = _comicComments[comicId] ?? const [];

      _comicComments[comicId] = [
        created,
        ...oldList,
      ];

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> createChapterComment({
    required int chapterId,
    required String content,
  }) async {
    final cleanContent = content.trim();

    if (cleanContent.isEmpty) {
      errorMessage = 'Vui lòng nhập nội dung bình luận';
      notifyListeners();
      return false;
    }

    if (cleanContent.length > 1000) {
      errorMessage = 'Bình luận không được vượt quá 1000 ký tự';
      notifyListeners();
      return false;
    }

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      final created = await commentService.createChapterComment(
        chapterId: chapterId,
        content: cleanContent,
      );

      final oldList = _chapterComments[chapterId] ?? const [];

      _chapterComments[chapterId] = [
        created,
        ...oldList,
      ];

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> replyComicComment({
    required int comicId,
    required int parentCommentId,
    required String content,
  }) async {
    final cleanContent = content.trim();

    if (cleanContent.isEmpty) {
      errorMessage = 'Vui lòng nhập nội dung phản hồi';
      notifyListeners();
      return false;
    }

    if (cleanContent.length > 1000) {
      errorMessage = 'Phản hồi không được vượt quá 1000 ký tự';
      notifyListeners();
      return false;
    }

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await commentService.replyComicComment(
        comicId: comicId,
        parentCommentId: parentCommentId,
        content: cleanContent,
      );

      await loadComicComments(comicId);

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> replyChapterComment({
    required int chapterId,
    required int parentCommentId,
    required String content,
  }) async {
    final cleanContent = content.trim();

    if (cleanContent.isEmpty) {
      errorMessage = 'Vui lòng nhập nội dung phản hồi';
      notifyListeners();
      return false;
    }

    if (cleanContent.length > 1000) {
      errorMessage = 'Phản hồi không được vượt quá 1000 ký tự';
      notifyListeners();
      return false;
    }

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await commentService.replyChapterComment(
        chapterId: chapterId,
        parentCommentId: parentCommentId,
        content: cleanContent,
      );

      await loadChapterComments(chapterId);

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearComicComments(int comicId) {
    _comicComments.remove(comicId);
    errorMessage = null;
    notifyListeners();
  }

  void clearChapterComments(int chapterId) {
    _chapterComments.remove(chapterId);
    errorMessage = null;
    notifyListeners();
  }
}
