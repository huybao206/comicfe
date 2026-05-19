import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../comic/model/comic.dart';
import '../../comic/provider/comic_provider.dart';
import '../../comic/screens/comic_detail_screen.dart';
import '../model/ranking_entry.dart';
import '../provider/ranking_provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

enum _RankingKind { user, comic }

class _RankingTab {
  const _RankingTab({
    required this.id,
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.kind,
    this.userType,
    this.comicSort,
  });

  final String id;
  final String label;
  final String title;
  final String description;
  final IconData icon;
  final _RankingKind kind;
  final String? userType;
  final String? comicSort;
}

class _RankingScreenState extends State<RankingScreen> {
  static const List<_RankingTab> _tabs = [
    _RankingTab(
      id: 'level',
      label: 'Cảnh giới',
      title: 'BXH Cấp độ / Cảnh giới',
      description: 'Xếp theo cảnh giới, cấp độ và kinh nghiệm tu luyện của người dùng.',
      icon: Icons.auto_awesome_rounded,
      kind: _RankingKind.user,
      userType: 'level',
    ),
    _RankingTab(
      id: 'vip',
      label: 'VIP',
      title: 'BXH VIP',
      description: 'Xếp theo cấp VIP, tổng nạp và điểm VIP của người dùng.',
      icon: Icons.workspace_premium_rounded,
      kind: _RankingKind.user,
      userType: 'vip',
    ),
    _RankingTab(
      id: 'wealth',
      label: 'Tài phú',
      title: 'BXH Tài phú',
      description: 'Xếp theo số dư vàng và tài nguyên tiền tệ trong hệ thống.',
      icon: Icons.account_balance_wallet_rounded,
      kind: _RankingKind.user,
      userType: 'wealth',
    ),
    _RankingTab(
      id: 'comic_follows',
      label: 'Truyện theo dõi',
      title: 'BXH Truyện theo dõi',
      description: 'Xếp hạng truyện có lượt theo dõi cao nhất.',
      icon: Icons.favorite_rounded,
      kind: _RankingKind.comic,
      comicSort: 'follows',
    ),
    _RankingTab(
      id: 'comic_views',
      label: 'Truyện lượt xem',
      title: 'BXH Truyện lượt xem',
      description: 'Xếp hạng truyện có lượt xem cao nhất.',
      icon: Icons.visibility_rounded,
      kind: _RankingKind.comic,
      comicSort: 'views',
    ),
  ];

  int _selectedIndex = 0;

  _RankingTab get _selectedTab => _tabs[_selectedIndex];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadSelectedTab());
  }

  Future<void> _loadSelectedTab() async {
    final tab = _selectedTab;

    if (tab.kind == _RankingKind.user) {
      await context.read<RankingProvider>().changeType(tab.userType!);
      return;
    }

    await context.read<ComicProvider>().loadComicRankings(
      sort: tab.comicSort!,
    );
  }

  Future<void> _refresh() => _loadSelectedTab();

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    Future.microtask(() => _loadSelectedTab());
  }

  void _openComicDetail(Comic comic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComicDetailScreen(comicId: comic.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = _selectedTab;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: RefreshIndicator(
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
          children: [
            _RankingHeader(tab: tab),
            const SizedBox(height: 14),
            _RankingTabBar(
              tabs: _tabs,
              selectedIndex: _selectedIndex,
              onSelect: _selectTab,
            ),
            const SizedBox(height: 14),
            if (tab.kind == _RankingKind.user)
              _UserRankingBody(
                tab: tab,
                formatNumber: _formatNumber,
              )
            else
              _ComicRankingBody(
                tab: tab,
                onComicTap: _openComicDetail,
                formatNumber: _formatNumber,
              ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(num value) {
    final n = value.toDouble();

    if (n >= 1000000000) {
      final result = n / 1000000000;
      return '${result.toStringAsFixed(result >= 10 ? 0 : 1)}B';
    }

    if (n >= 1000000) {
      final result = n / 1000000;
      return '${result.toStringAsFixed(result >= 10 ? 0 : 1)}M';
    }

    if (n >= 1000) {
      final result = n / 1000;
      return '${result.toStringAsFixed(result >= 10 ? 0 : 1)}K';
    }

    return value.toInt().toString();
  }
}

class _RankingHeader extends StatelessWidget {
  const _RankingHeader({required this.tab});

  final _RankingTab tab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF7A5A26)),
        gradient: const RadialGradient(
          center: Alignment.topRight,
          radius: 1.25,
          colors: [
            Color(0xFF5C4217),
            Color(0xFF22284F),
            Color(0xFF0B1020),
          ],
          stops: [0, 0.46, 1],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD27A), Color(0xFFD4A02F)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              tab.icon,
              color: const Color(0xFF211407),
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tab.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  tab.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD7C39A),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingTabBar extends StatelessWidget {
  const _RankingTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_RankingTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final selected = index == selectedIndex;

          return Padding(
            padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
            child: InkWell(
              onTap: () => onSelect(index),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                    colors: [Color(0xFFFFD27A), Color(0xFFD4A02F)],
                  )
                      : null,
                  color: selected ? null : const Color(0xFF10182B),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? const Color(0xFFFFE9B0) : const Color(0xFF263756),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: 16,
                      color: selected ? const Color(0xFF211407) : Colors.white.withOpacity(0.78),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: selected ? const Color(0xFF211407) : Colors.white.withOpacity(0.82),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _UserRankingBody extends StatelessWidget {
  const _UserRankingBody({
    required this.tab,
    required this.formatNumber,
  });

  final _RankingTab tab;
  final String Function(num value) formatNumber;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RankingProvider>();
    final entries = provider.rankingEntries;

    if (provider.isLoading && entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 110),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4A02F)),
        ),
      );
    }

    if (provider.errorMessage != null && entries.isEmpty) {
      return _ErrorCard(
        message: provider.errorMessage!,
        onRetry: () => context.read<RankingProvider>().changeType(tab.userType!),
      );
    }

    if (entries.isEmpty) {
      return const _EmptyCard(message: 'Chưa có dữ liệu bảng xếp hạng người dùng.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: tab.title,
          action: 'Top ${entries.length}',
          icon: tab.icon,
        ),
        const SizedBox(height: 10),
        if (provider.myRanking != null) ...[
          _MyRankingCard(
            entry: provider.myRanking!,
            valueText: _entryValue(provider.myRanking!, tab, formatNumber),
            valueLabel: _entryLabel(tab),
          ),
          const SizedBox(height: 14),
        ],
        ...entries.map(
              (entry) => _UserRankingTile(
            entry: entry,
            valueText: _entryValue(entry, tab, formatNumber),
            valueLabel: _entryLabel(tab),
          ),
        ),
      ],
    );
  }

  String _entryValue(
      RankingEntry entry,
      _RankingTab tab,
      String Function(num value) formatNumber,
      ) {
    if (tab.id == 'level') {
      if ((entry.realmName ?? '').trim().isNotEmpty && entry.level > 0) {
        return '${entry.realmName} ${entry.level}';
      }
      if ((entry.realmName ?? '').trim().isNotEmpty) return entry.realmName!;
      if (entry.level > 0) return 'Cấp ${entry.level}';
      return formatNumber(entry.score);
    }

    if (tab.id == 'vip') {
      if ((entry.vipName ?? '').trim().isNotEmpty) return entry.vipName!;
      if (entry.vipLevel > 0) return 'VIP ${entry.vipLevel}';
      return 'VIP 0';
    }

    if (tab.id == 'wealth') {
      return formatNumber(entry.goldBalance > 0 ? entry.goldBalance : entry.score);
    }

    return formatNumber(entry.displayScore);
  }

  String _entryLabel(_RankingTab tab) {
    if (tab.id == 'level') return 'cảnh giới';
    if (tab.id == 'vip') return 'cấp VIP';
    if (tab.id == 'wealth') return 'vàng';
    return 'điểm';
  }
}

class _ComicRankingBody extends StatelessWidget {
  const _ComicRankingBody({
    required this.tab,
    required this.onComicTap,
    required this.formatNumber,
  });

  final _RankingTab tab;
  final ValueChanged<Comic> onComicTap;
  final String Function(num value) formatNumber;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComicProvider>();
    final comics = provider.topComics;

    if (provider.isRankingLoading && comics.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 110),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4A02F)),
        ),
      );
    }

    if (provider.rankingErrorMessage != null && comics.isEmpty) {
      return _ErrorCard(
        message: provider.rankingErrorMessage!,
        onRetry: () => context.read<ComicProvider>().loadComicRankings(sort: tab.comicSort!),
      );
    }

    if (comics.isEmpty) {
      return const _EmptyCard(message: 'Chưa có dữ liệu bảng xếp hạng truyện.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: tab.title,
          action: 'Top ${comics.length}',
          icon: tab.icon,
        ),
        const SizedBox(height: 10),
        ...List.generate(comics.length, (index) {
          final comic = comics[index];
          final value = tab.id == 'comic_follows' ? comic.totalFollows : comic.totalViews;
          final label = tab.id == 'comic_follows' ? 'theo dõi' : 'lượt xem';

          return _ComicRankingTile(
            comic: comic,
            rank: index + 1,
            valueText: formatNumber(value),
            valueLabel: label,
            onTap: () => onComicTap(comic),
          );
        }),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.icon,
  });

  final String title;
  final String action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
          child: Icon(icon, size: 18, color: const Color(0xFFBFD0FF)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 16,
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

class _MyRankingCard extends StatelessWidget {
  const _MyRankingCard({
    required this.entry,
    required this.valueText,
    required this.valueLabel,
  });

  final RankingEntry entry;
  final String valueText;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF172345), Color(0xFF10182B)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD4A02F).withOpacity(0.58)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD27A), Color(0xFFD4A02F)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_pin_circle_rounded, color: Color(0xFF211407), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thứ hạng của bạn',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.54),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                if (entry.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.52), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          _ValueColumn(rank: entry.rank, valueText: valueText, valueLabel: valueLabel),
        ],
      ),
    );
  }
}

class _UserRankingTile extends StatelessWidget {
  const _UserRankingTile({
    required this.entry,
    required this.valueText,
    required this.valueLabel,
  });

  final RankingEntry entry;
  final String valueText;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    final accent = _rankColor(entry.rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: entry.rank <= 3 ? accent.withOpacity(0.62) : const Color(0xFF263756),
        ),
      ),
      child: Row(
        children: [
          _RankBadge(rank: entry.rank, color: accent),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF18213A),
            backgroundImage: (entry.avatarUrl ?? '').trim().isNotEmpty ? NetworkImage(entry.avatarUrl!) : null,
            child: (entry.avatarUrl ?? '').trim().isEmpty
                ? Icon(Icons.person_outline_rounded, color: accent, size: 23)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                  ),
                ),
                if (entry.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.52), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ValueColumn(rank: entry.rank, valueText: valueText, valueLabel: valueLabel),
        ],
      ),
    );
  }
}

class _ComicRankingTile extends StatelessWidget {
  const _ComicRankingTile({
    required this.comic,
    required this.rank,
    required this.valueText,
    required this.valueLabel,
    required this.onTap,
  });

  final Comic comic;
  final int rank;
  final String valueText;
  final String valueLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _rankColor(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: rank <= 3 ? accent.withOpacity(0.62) : const Color(0xFF263756),
              ),
            ),
            child: Row(
              children: [
                _RankBadge(rank: rank, color: accent),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _CoverImage(url: comic.coverImageUrl, width: 50, height: 66),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comic.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFFE9B0),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${comic.totalChapters} chương${(comic.genres ?? '').trim().isNotEmpty ? ' • ${comic.genres}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.48), fontSize: 11.5),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${comic.totalViews} lượt xem • ${comic.totalFollows} theo dõi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ValueColumn(rank: rank, valueText: valueText, valueLabel: valueLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.color});

  final int rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ),
    );
  }
}

class _ValueColumn extends StatelessWidget {
  const _ValueColumn({
    required this.rank,
    required this.valueText,
    required this.valueLabel,
  });

  final int rank;
  final String valueText;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 54, maxWidth: 78),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            valueText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontWeight: FontWeight.w900,
              fontSize: 13.2,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valueLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url, required this.width, required this.height});

  final String? url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.trim().isNotEmpty) {
      return Image.network(
        url!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF18213A),
      child: const Icon(Icons.menu_book_outlined, color: Colors.white54),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 70),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined, color: Color(0xFFFFD27A), size: 46),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 70),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFFD27A), size: 44),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.62), fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4A02F),
              foregroundColor: const Color(0xFF211407),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

Color _rankColor(int rank) {
  if (rank == 1) return const Color(0xFFFFD27A);
  if (rank == 2) return const Color(0xFFC7D2E0);
  if (rank == 3) return const Color(0xFFD7A26B);

  return const Color(0xFF8FB0FF);
}
