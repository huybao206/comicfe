import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/ranking_entry.dart';
import '../model/ranking_type.dart';
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

  Future<void> _refresh() async {
    await context.read<RankingProvider>().loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RankingProvider>();

    final selectedType = _selectedType(provider);
    final selectedTypeName = selectedType?.name.trim().isNotEmpty == true
        ? selectedType!.name
        : selectedType?.typeCode ?? 'BXH';

    final topEntries = provider.rankingEntries.take(3).toList();
    final remainingEntries = provider.rankingEntries.length > 3
        ? provider.rankingEntries.skip(3).toList()
        : <RankingEntry>[];

    final topScore = provider.rankingEntries.isNotEmpty
        ? provider.rankingEntries.first.displayScore
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: RefreshIndicator(
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: [
            RankingHeader(
              totalEntries: provider.rankingEntries.length,
              topScore: topScore,
              selectedTypeName: selectedTypeName,
            ),
            const SizedBox(height: 14),
            if (provider.rankingTypes.isNotEmpty) ...[
              _sectionHeader(
                title: 'Loại bảng xếp hạng',
                icon: Icons.tune_rounded,
                action: '${provider.rankingTypes.length} loại',
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.rankingTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final type = provider.rankingTypes[index];

                    return RankingTypeChip(
                      label: type.name.isNotEmpty
                          ? type.name
                          : type.typeCode,
                      selected:
                      provider.selectedTypeCode == type.typeCode,
                      onTap: () {
                        context
                            .read<RankingProvider>()
                            .changeType(type.typeCode);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (provider.isLoading && provider.rankingEntries.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4A02F),
                  ),
                ),
              )
            else if (provider.errorMessage != null &&
                provider.rankingEntries.isEmpty)
              _RankingErrorView(
                message: provider.errorMessage!,
                onRetry: _refresh,
              )
            else if (provider.rankingEntries.isEmpty)
                const RankingEmptyView()
              else ...[
                  _sectionHeader(
                    title: 'Top thiên kiêu',
                    icon: Icons.emoji_events_rounded,
                    action: 'Top 3',
                  ),
                  const SizedBox(height: 12),
                  _TopThreePodium(entries: topEntries),
                  const SizedBox(height: 18),
                  if (provider.myRanking != null) ...[
                    _sectionHeader(
                      title: 'Thứ hạng của bạn',
                      icon: Icons.person_pin_circle_outlined,
                      action: '#${provider.myRanking!.rank}',
                    ),
                    const SizedBox(height: 10),
                    RankingMeCard(entry: provider.myRanking!),
                    const SizedBox(height: 18),
                  ],
                  _sectionHeader(
                    title: 'Bảng tổng sắp',
                    icon: Icons.format_list_numbered_rounded,
                    action: '${provider.rankingEntries.length} người',
                  ),
                  const SizedBox(height: 10),
                  if (remainingEntries.isEmpty)
                    ...provider.rankingEntries.map(
                          (entry) => RankingUserTile(entry: entry),
                    )
                  else
                    ...remainingEntries.map(
                          (entry) => RankingUserTile(entry: entry),
                    ),
                ],
          ],
        ),
      ),
    );
  }

  RankingType? _selectedType(RankingProvider provider) {
    for (final type in provider.rankingTypes) {
      if (type.typeCode == provider.selectedTypeCode) {
        return type;
      }
    }

    return provider.rankingTypes.isNotEmpty
        ? provider.rankingTypes.first
        : null;
  }

  Widget _sectionHeader({
    required String title,
    required IconData icon,
    required String action,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF6574FF).withOpacity(0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3E4EA8)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFBFD0FF),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          action,
          style: TextStyle(
            color: Colors.white.withOpacity(0.48),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  const _TopThreePodium({
    required this.entries,
  });

  final List<RankingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final rank1 = _getByRank(1);
    final rank2 = _getByRank(2);
    final rank3 = _getByRank(3);

    return Container(
      height: 246,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _PodiumUser(
              entry: rank2,
              rank: 2,
              height: 150,
              color: const Color(0xFFC7D2E0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PodiumUser(
              entry: rank1,
              rank: 1,
              height: 188,
              color: const Color(0xFFFFD27A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PodiumUser(
              entry: rank3,
              rank: 3,
              height: 132,
              color: const Color(0xFFD7A26B),
            ),
          ),
        ],
      ),
    );
  }

  RankingEntry? _getByRank(int rank) {
    for (final entry in entries) {
      if (entry.rank == rank) return entry;
    }

    if (entries.length >= rank) {
      return entries[rank - 1];
    }

    return null;
  }
}

class _PodiumUser extends StatelessWidget {
  const _PodiumUser({
    required this.entry,
    required this.rank,
    required this.height,
    required this.color,
  });

  final RankingEntry? entry;
  final int rank;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: rank == 1 ? 58 : 50,
            height: rank == 1 ? 58 : 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF18213A),
              backgroundImage:
              (entry?.avatarUrl ?? '').trim().isNotEmpty
                  ? NetworkImage(entry!.avatarUrl!)
                  : null,
              child: (entry?.avatarUrl ?? '').trim().isEmpty
                  ? Icon(
                Icons.person_rounded,
                color: color,
                size: rank == 1 ? 29 : 24,
              )
                  : null,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            entry?.name ?? 'Chưa có',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry != null ? '${entry!.displayScore}' : '-',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: rank == 1
                ? 68
                : rank == 2
                ? 50
                : 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.90),
                  color.withOpacity(0.32),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border.all(color: color.withOpacity(0.70)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: const Color(0xFF07101F),
                  fontWeight: FontWeight.w900,
                  fontSize: rank == 1 ? 22 : 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingErrorView extends StatelessWidget {
  const _RankingErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 72),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFFD27A),
            size: 46,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không tải được bảng xếp hạng',
            style: TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.54),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4A02F),
              foregroundColor: const Color(0xFF211407),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Thử lại',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}