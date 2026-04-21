import 'package:flutter/material.dart';

import '../model/afk_claim_result.dart';
import '../model/afk_config.dart';
import '../model/afk_session.dart';
import '../service/afk_service.dart';

class AfkProvider extends ChangeNotifier {
  AfkProvider({
    required this.afkService,
  });

  final AfkService afkService;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  List<AfkConfig> configs = [];
  AfkSession? activeSession;
  AfkClaimResult? claimResult;

  Future<void> loadConfigs() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      configs = await afkService.getAfkConfigs();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startSession() async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      activeSession = await afkService.startAfkSession();
      claimResult = null;
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> finishSession({
    required int sessionId,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      activeSession = await afkService.finishAfkSession(sessionId: sessionId);
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> claimSession({
    required int sessionId,
  }) async {
    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      claimResult = await afkService.claimAfkSession(sessionId: sessionId);
      activeSession = null;
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearResult() {
    claimResult = null;
    notifyListeners();
  }
}