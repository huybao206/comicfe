import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../model/user_profile.dart';

class UserService {
  UserService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<UserProfile> getMyProfile() async {
    final data = await apiClient.get(ApiPaths.me);
    return UserProfile.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> updateProfile({
    required String displayName,
  }) async {
    throw UnimplementedError(
      'Backend chưa có API update profile cho app user',
    );
  }
}