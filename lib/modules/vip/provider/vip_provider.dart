import 'package:flutter/material.dart';

import '../model/my_vip.dart';
import '../model/vip_feature.dart';
import '../model/vip_level.dart';
import '../service/vip_service.dart';

class VipProvider extends ChangeNotifier {
  VipProvider({
    required this.vipService,
  });

  final VipService vipService;

  bool isLoading = false;
  String? errorMessage;

  List<VipLevel> levels = [];
  List<VipFeature> features = [];
  MyVip? myVip;

  Future<void> loadAll() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      levels = await vipService.getVipLevels();
      features = await vipService.getVipFeatures();

      try {
        myVip = await vipService.getMyVip();
      } catch (_) {
        myVip = null;
      }
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}