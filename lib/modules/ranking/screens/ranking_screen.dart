import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/ranking_provider.dart';
import '../widgets/ranking_empty_view.dart';
import '../widgets/ranking_header.dart';
import '../widgets/ranking_me_card.dart';
import '../widgets/ranking_type_chip.dart';
import '../widgets/ranking_user_tile.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RankingProvider>().loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RankingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: () => context.read<RankingProvider>().loadInitial(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const RankingHeader(),
            if (provider.rankingTypes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.rankingTypes.map((type) {
                    return RankingTypeChip(
                      label: type.name.isNotEmpty ? type.name : type.typeCode,
                      selected: provider.selectedTypeCode == type.typeCode,
                      onTap: () => context
                          .read<RankingProvider>()
                          .changeType(type.typeCode),
                    );
                  }).toList(),
                ),
              ),
            if (provider.isLoading && provider.rankingEntries.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFC7962F),
                  ),
                ),
              )
            else if (provider.errorMessage != null &&
                provider.rankingEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE6D4AC),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
            else if (provider.rankingEntries.isEmpty)
                const RankingEmptyView()
              else ...[
                  if (provider.myRanking != null)
                    RankingMeCard(entry: provider.myRanking!),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      children: provider.rankingEntries
                          .map((entry) => RankingUserTile(entry: entry))
                          .toList(),
                    ),
                  ),
                ],
          ],
        ),
      ),
    );
  }
}