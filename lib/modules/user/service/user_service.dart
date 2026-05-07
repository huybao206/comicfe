import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/user_profile.dart';

class UserService {
  UserService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<UserProfile> getMyProfile() async {
    try {
      final data = await apiClient.get(ApiPaths.myProfile);

      return UserProfile.fromMap(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (_) {
      // Nếu /profile/me lỗi do BE/DB, vẫn lấy user cơ bản từ /auth/me
      // để màn Tôi không bị trống.
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
  }) async {
    final data = await apiClient.put(
      ApiPaths.updateMyProfile,
      data: {
        'display_name': displayName.trim(),
        if (bio != null) 'bio': bio.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl.trim(),
      },
    );

    return UserProfile.fromMap(
      Map<String, dynamic>.from(data as Map),
    );
  }
}