import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/storage/token_storage.dart';
import '../model/auth_user.dart';

class AuthService {
  AuthService({
    required this.apiClient,
    required this.tokenStorage,
  });

  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  Future<AuthUser> login({
    required String identifier,
    required String password,
  }) async {
    final data = await apiClient.post(
      ApiPaths.login,
      data: {
        'identifier': identifier.trim(),
        'password': password.trim(),
      },
    );

    final body = Map<String, dynamic>.from(data as Map);

    final accessToken = (body['accessToken'] ?? '').toString();
    final refreshToken = (body['refreshToken'] ?? '').toString();
    final sessionToken = (body['sessionToken'] ?? '').toString();

    if (accessToken.isNotEmpty) {
      await tokenStorage.saveAccessToken(accessToken);
    }

    if (refreshToken.isNotEmpty) {
      await tokenStorage.saveRefreshToken(refreshToken);
    }

    if (sessionToken.isNotEmpty) {
      await tokenStorage.saveSessionToken(sessionToken);
    }

    final userMap = Map<String, dynamic>.from(body['user'] ?? {});
    return AuthUser.fromMap(userMap);
  }

  Future<AuthUser> register({
    required String username,
    required String email,
    required String displayName,
    required String password,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email.trim().toLowerCase();
    final cleanDisplayName = displayName.trim();
    final cleanPassword = password.trim();

    if (cleanUsername.length < 6) {
      throw Exception('Username phải từ 6 ký tự trở lên');
    }

    final usernameRegex = RegExp(r'^[a-z0-9_]+$');
    if (!usernameRegex.hasMatch(cleanUsername)) {
      throw Exception('Username chỉ được chữ thường, số và dấu _');
    }

    if (cleanPassword.length < 6) {
      throw Exception('Mật khẩu phải từ 6 ký tự trở lên');
    }

    await apiClient.post(
      ApiPaths.register,
      data: {
        'username': cleanUsername,
        'email': cleanEmail,
        'displayName': cleanDisplayName,
        'password': cleanPassword,
      },
    );

    // BE register hiện chỉ trả userId/verifyToken, chưa trả accessToken.
    // Vì vậy sau khi đăng ký thành công, FE tự login luôn để lấy token.
    return login(
      identifier: cleanUsername,
      password: cleanPassword,
    );
  }

  Future<AuthUser> getMe() async {
    final data = await apiClient.get(ApiPaths.me);
    return AuthUser.fromMap(Map<String, dynamic>.from(data as Map));
  }


  Future<void> forgotPassword({
    required String email,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw Exception('Email không hợp lệ');
    }

    await apiClient.post(
      ApiPaths.forgotPassword,
      data: {
        'email': cleanEmail,
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = otp.trim();
    final cleanPassword = newPassword.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw Exception('Email không hợp lệ');
    }

    if (!RegExp(r'^\d{6}$').hasMatch(cleanOtp)) {
      throw Exception('OTP phải gồm 6 số');
    }

    if (cleanPassword.length < 6) {
      throw Exception('Mật khẩu mới phải từ 6 ký tự trở lên');
    }

    await apiClient.post(
      ApiPaths.resetPassword,
      data: {
        'email': cleanEmail,
        'otp': cleanOtp,
        'newPassword': cleanPassword,
      },
    );
  }

  Future<void> requestChangePasswordOtp() async {
    await apiClient.post(ApiPaths.requestChangePasswordOtp);
  }

  Future<void> confirmChangePasswordWithOtp({
    required String otp,
    required String newPassword,
  }) async {
    final cleanOtp = otp.trim();
    final cleanPassword = newPassword.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(cleanOtp)) {
      throw Exception('OTP phải gồm 6 số');
    }

    if (cleanPassword.length < 6) {
      throw Exception('Mật khẩu mới phải từ 6 ký tự trở lên');
    }

    await apiClient.post(
      ApiPaths.confirmChangePasswordOtp,
      data: {
        'otp': cleanOtp,
        'newPassword': cleanPassword,
      },
    );
  }

  Future<void> logout() async {
    try {
      final sessionToken = await tokenStorage.getSessionToken();

      if (sessionToken != null && sessionToken.isNotEmpty) {
        await apiClient.post(
          ApiPaths.logout,
          data: {
            'tokenValue': sessionToken,
          },
        );
      }
    } catch (_) {
      // Vẫn clear token local dù BE logout lỗi.
    } finally {
      await tokenStorage.clear();
    }
  }
}