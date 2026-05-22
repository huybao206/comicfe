import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/profile_utility_models.dart';
import '../model/user_profile.dart';

class UserService {
  UserService({required this.apiClient});

  final ApiClient apiClient;

  Future<UserProfile> getMyProfile() async {
    try {
      final data = await apiClient.get(ApiPaths.myProfile);

      return UserProfile.fromMap(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (_) {
      final fallbackData = await apiClient.get(ApiPaths.me);

      return UserProfile.fromMap(
        Map<String, dynamic>.from(fallbackData as Map),
      );
    }
  }

  Future<UserProfile> updateProfile({
    required String displayName,
    String? bio,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    dynamic payload;

    if (avatarFile != null) {
      payload = FormData.fromMap({
        'display_name': displayName.trim(),
        if (bio != null) 'bio': bio.trim(),
        if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          'avatar_url': avatarUrl.trim(),
        'avatar_image': await MultipartFile.fromFile(
          avatarFile.path,
          filename: avatarFile.path.split(Platform.pathSeparator).last,
        ),
      });
    } else {
      payload = {
        'display_name': displayName.trim(),
        if (bio != null) 'bio': bio.trim(),
        if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          'avatar_url': avatarUrl.trim(),
      };
    }

    final data = await apiClient.put(
      ApiPaths.updateMyProfile,
      data: payload,
    );

    return UserProfile.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }

  Future<List<ReadingHistoryItem>> getMyReadingHistory({int limit = 50}) async {
    final data = await apiClient.get(
      ApiPaths.myReadingHistory,
      queryParameters: {'limit': limit},
    );

    return _extractItems(data)
        .whereType<Map>()
        .map((item) => ReadingHistoryItem.fromMap(Map<String, dynamic>.from(item)))
        .where((item) => item.comicId > 0 && item.chapterId > 0)
        .toList();
  }

  Future<List<FollowedComicItem>> getMyFollowedComics() async {
    final data = await apiClient.get(ApiPaths.myFollowedComics);

    return _extractItems(data)
        .whereType<Map>()
        .map((item) => FollowedComicItem.fromMap(Map<String, dynamic>.from(item)))
        .where((item) => item.comicId > 0)
        .toList();
  }

  Future<InventoryData> getMyInventory() async {
    final data = await apiClient.get(ApiPaths.myInventory);

    return InventoryData.fromMap(
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
    );
  }

  Future<InventoryUseResult> useInventoryItem({
    required int itemId,
    int quantity = 1,
  }) async {
    final data = await apiClient.post(
      ApiPaths.useInventoryItem,
      data: {
        'item_id': itemId,
        'quantity': quantity,
      },
    );

    return InventoryUseResult.fromMap(
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
    );
  }

  List _extractItems(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['items'] is List) return map['items'] as List;
      if (map['rows'] is List) return map['rows'] as List;
      if (map['results'] is List) return map['results'] as List;
      if (map['data'] is List) return map['data'] as List;

      if (map['data'] is Map) {
        final nested = Map<String, dynamic>.from(map['data'] as Map);
        if (nested['items'] is List) return nested['items'] as List;
        if (nested['rows'] is List) return nested['rows'] as List;
        if (nested['results'] is List) return nested['results'] as List;
      }
    }

    return const [];
  }
}
