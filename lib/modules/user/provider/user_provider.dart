import 'dart:io';

import 'package:flutter/material.dart';

import '../model/user_profile.dart';
import '../service/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({required this.userService});

  final UserService userService;

  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

  UserProfile? profile;

  Future<void> loadMyProfile() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      profile = await userService.getMyProfile();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    String? bio,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    final cleanDisplayName = displayName.trim();

    if (cleanDisplayName.isEmpty) {
      errorMessage = 'Tên hiển thị không được để trống';
      notifyListeners();
      return false;
    }

    try {
      isUpdating = true;
      errorMessage = null;
      notifyListeners();

      profile = await userService.updateProfile(
        displayName: cleanDisplayName,
        bio: bio,
        avatarUrl: avatarUrl,
        avatarFile: avatarFile,
      );

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  void clear() {
    profile = null;
    errorMessage = null;
    notifyListeners();
  }
}
