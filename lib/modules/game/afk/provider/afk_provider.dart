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

  Future<void> bootstrap() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        afkService.getAfkConfigs(),
        afkService.getRunningSession(),
      ]);

      configs = results[0] as List<AfkConfig>;
      activeSession = results[1] as AfkSession?;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> loadRunningSession() async {
    try {
      activeSession = await afkService.getRunningSession();
      notifyListeners();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> startSession() async {
    try {
      isSubmitting = true;
      errorMessage = null;
      claimResult = null;
      notifyListeners();

      activeSession = await afkService.startAfkSession();
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

      activeSession = await afkService.finishAfkSession(
        sessionId: sessionId,
      );

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

      claimResult = await afkService.claimAfkSession(
        sessionId: sessionId,
      );

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

  AfkConfig? findConfig(String key) {
    for (final config in configs) {
      if (config.configKey == key) {
        return config;
      }
    }

    return null;
  }

  bool get afkEnabled {
    final raw = findConfig('afk_enabled')?.parsedValue ??
        findConfig('afk_enabled')?.configValue;

    if (raw is bool) return raw;

    final text = raw?.toString().trim().toLowerCase();

    return text == null ||
        text.isEmpty ||
        text == 'true' ||
        text == '1' ||
        text == 'yes';
  }

  double get expPerMinute => _configNumber(
    ['afk_exp_per_minute', 'afk_base_exp_per_minute'],
    fallback: 0,
  );

  double get goldPerMinute => _configNumber(
    ['afk_gold_per_minute'],
    fallback: 0,
  );

  double get vipBonusPercent => _configNumber(
    ['afk_vip_bonus_percent'],
    fallback: 0,
  );

  String? get bannerImageUrl {
    final raw = findConfig('afk_banner_image_url')?.parsedValue ??
        findConfig('afk_banner_image_url')?.configValue ??
        findConfig('afk_image_url')?.parsedValue ??
        findConfig('afk_image_url')?.configValue;

    final value = raw?.toString().trim();

    if (value == null || value.isEmpty || value == 'null') return null;

    return value;
  }


  double get commonBonusPercent => _configNumber(
    ['afk_bonus_percent'],
    fallback: 0,
  );

  int get minMinutesToClaim => _configNumber(
    ['afk_min_minutes_to_claim'],
    fallback: 0,
  ).round();

  int get maxMinutesPerSession => _configNumber(
    ['afk_max_minutes_per_session'],
    fallback: 480,
  ).round();

  int get dailyMaxMinutes => _configNumber(
    ['afk_daily_max_minutes'],
    fallback: 720,
  ).round();

  double _configNumber(
      List<String> keys, {
        required double fallback,
      }) {
    for (final key in keys) {
      final config = findConfig(key);

      if (config == null) continue;

      final parsed = config.parsedValue;

      if (parsed is num) return parsed.toDouble();

      final fromParsed = double.tryParse(parsed?.toString() ?? '');
      if (fromParsed != null) return fromParsed;

      final fromRaw = double.tryParse(config.configValue ?? '');
      if (fromRaw != null) return fromRaw;
    }

    return fallback;
  }
}