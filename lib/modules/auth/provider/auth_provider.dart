import 'package:flutter/material.dart';

import '../model/auth_user.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this.authService,
  });

  final AuthService authService;

  bool isBooting = true;
  bool isLoading = false;
  AuthUser? currentUser;
  String? errorMessage;

  bool get isLoggedIn => currentUser != null;

  Future<void> bootstrap() async {
    try {
      errorMessage = null;
      currentUser = await authService.getMe();
    } catch (_) {
      currentUser = null;
    } finally {
      isBooting = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final cleanIdentifier = identifier.trim();
      final cleanPassword = password.trim();

      if (cleanIdentifier.isEmpty) {
        errorMessage = 'Vui lòng nhập email hoặc username';
        return false;
      }

      if (!cleanIdentifier.contains('@') && cleanIdentifier.length < 6) {
        errorMessage = 'Username phải từ 6 ký tự trở lên';
        return false;
      }

      if (cleanPassword.isEmpty) {
        errorMessage = 'Vui lòng nhập mật khẩu';
        return false;
      }

      if (cleanPassword.length < 6) {
        errorMessage = 'Mật khẩu phải từ 6 ký tự trở lên';
        return false;
      }

      currentUser = await authService.login(
        identifier: cleanIdentifier,
        password: cleanPassword,
      );

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String displayName,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final cleanUsername = username.trim().toLowerCase();
      final cleanEmail = email.trim().toLowerCase();
      final cleanDisplayName = displayName.trim();
      final cleanPassword = password.trim();

      if (cleanUsername.isEmpty) {
        errorMessage = 'Vui lòng nhập username';
        return false;
      }

      if (cleanUsername.length < 6) {
        errorMessage = 'Username phải từ 6 ký tự trở lên';
        return false;
      }

      final usernameRegex = RegExp(r'^[a-z0-9_]+$');

      if (!usernameRegex.hasMatch(cleanUsername)) {
        errorMessage = 'Username chỉ được chữ thường, số và dấu _';
        return false;
      }

      if (cleanEmail.isEmpty) {
        errorMessage = 'Vui lòng nhập email';
        return false;
      }

      if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
        errorMessage = 'Email không hợp lệ';
        return false;
      }

      if (cleanDisplayName.isEmpty) {
        errorMessage = 'Vui lòng nhập tên hiển thị';
        return false;
      }

      if (cleanPassword.isEmpty) {
        errorMessage = 'Vui lòng nhập mật khẩu';
        return false;
      }

      if (cleanPassword.length < 6) {
        errorMessage = 'Mật khẩu phải từ 6 ký tự trở lên';
        return false;
      }

      // Điểm quan trọng:
      // authService.register sẽ đăng ký xong rồi tự login luôn.
      currentUser = await authService.register(
        username: cleanUsername,
        email: cleanEmail,
        displayName: cleanDisplayName,
        password: cleanPassword,
      );

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await authService.logout();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      currentUser = null;
      isLoading = false;
      notifyListeners();
    }
  }
}