import 'package:flutter/foundation.dart';

import '../model/mission_item.dart';
import '../service/mission_service.dart';

class MissionProvider extends ChangeNotifier {
  MissionProvider({required MissionService missionService})
      : _missionService = missionService;

  final MissionService _missionService;

  List<MissionItem> _missions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedType = 'all';

  List<MissionItem> get missions => _missions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedType => _selectedType;

  List<MissionItem> get filteredMissions {
    if (_selectedType == 'all') return _missions;
    return _missions
        .where((item) => item.missionType.toLowerCase() == _selectedType)
        .toList();
  }

  Future<void> loadMissions({String? type}) async {
    _isLoading = true;
    _errorMessage = null;
    if (type != null) _selectedType = type;
    notifyListeners();

    try {
      _missions = await _missionService.getMyMissions(type: _selectedType);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setType(String type) async {
    _selectedType = type;
    await loadMissions(type: type);
  }

  Future<void> changeType(String type) => setType(type);

  Future<bool> claimMissionReward(int missionId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _missionService.claimMissionReward(missionId);
      await loadMissions(type: _selectedType);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> claimReward(int missionId) => claimMissionReward(missionId);
}
