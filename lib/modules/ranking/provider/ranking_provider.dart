import 'package:flutter/material.dart';

import '../model/ranking_entry.dart';
import '../model/ranking_type.dart';
import '../service/ranking_service.dart';

class RankingProvider extends ChangeNotifier {
  RankingProvider({
    required this.rankingService,
  });

  final RankingService rankingService;

  bool isLoading = false;
  String? errorMessage;

  List<RankingType> rankingTypes = [];
  List<RankingEntry> rankingEntries = [];
  RankingEntry? myRanking;
  String? selectedTypeCode;

  Future<void> loadInitial() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      rankingTypes = await rankingService.getRankingTypes();

      if (rankingTypes.isNotEmpty) {
        selectedTypeCode = rankingTypes.first.typeCode;
        await _loadRankingForType(selectedTypeCode!);
      }
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeType(String typeCode) async {
    try {
      isLoading = true;
      errorMessage = null;
      selectedTypeCode = typeCode;
      notifyListeners();

      await _loadRankingForType(typeCode);
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRankingForType(String typeCode) async {
    rankingEntries = await rankingService.getRankingByType(typeCode);
    myRanking = await rankingService.getMyRankingByType(typeCode);
  }
}