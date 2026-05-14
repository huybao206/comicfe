import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/comic.dart';
import '../provider/comic_provider.dart';
import 'comic_detail_screen.dart';

class ComicListScreen extends StatefulWidget {
  const ComicListScreen({super.key});

  @override
  State<ComicListScreen> createState() => _ComicListScreenState();
}

class _ComicListScreenState extends State<ComicListScreen> {
  final _searchController = TextEditingController();

  int selectedCategoryIndex = 0;

  final List<_ComicCategory> categories = const [
    _ComicCategory('Tất cả', Icons.auto_stories_outlined),
    _ComicCategory('Tu tiên', Icons.auto_awesome_outlined),
    _ComicCategory('Action', Icons.local_fire_department_outlined),
    _ComicCategory('Romance', Icons.favorite_outline_rounded),
    _ComicCategory('Fantasy', Icons.public_outlined),
    _ComicCategory('Comedy', Icons.sentiment_satisfied_alt_rounded),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ComicProvider>().loadComics();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<ComicProvider>().loadComics(
      keyword: _searchController.text.trim(),
    );
  }

  void _search() {
    FocusScope.of(context).unfocus();

    context.read<ComicProvider>().loadComics(
      keyword: _searchController.text.trim(),
    );
  }

  void _openDetail(Comic comic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComicDetailScreen(comicId: comic.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComicProvider>();
    final comics = provider.comics;

    final featured = comics.isNotEmpty ? comics.first : null;
    final continueComic = comics.length > 1 ? comics[1] : featured;
    final latest = comics;
    final recommended = comics.length > 2 ? comics.skip(1).take(8).toList() : comics;
    final topComics = comics.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: RefreshIndicator(
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        onRefresh: _refresh,
        child: Builder(
          builder: (_) {
            if (provider.isLoading && comics.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4A02F),
                ),
              );
            }

            if (provider.errorMessage != null && comics.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 150),
                  _ErrorView(
                    message: provider.errorMessage!,
                    onRetry: _refresh,
                  ),
                ],
              );
            }

            if (comics.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
                children: [
                  _searchBox(),
                  const SizedBox(height: 130),
                  _EmptyView(onRetry: _refresh),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
              children: [
                _searchBox(),
                const SizedBox(height: 14),

                if (featured != null) _heroBanner(featured),

                const SizedBox(height: 14),

                if (continueComic != null) _continueReadingCard(continueComic),

                const SizedBox(height: 18),

                _sectionHeader(
                  title: 'Thể loại nổi bật',
                  icon: Icons.grid_view_rounded,
                  action: 'Tất cả',
                ),
                const SizedBox(height: 10),
                _categoryRow(),

                const SizedBox(height: 18),

                _sectionHeader(
                  title: 'Đề cử hôm nay',
                  icon: Icons.stars_rounded,
                  action: 'Xem thêm',
                ),
                const SizedBox(height: 10),
                _horizontalComicList(recommended),

                const SizedBox(height: 18),

                _sectionHeader(
                  title: 'Mới cập nhật',
                  icon: Icons.update_rounded,
                  action: '${latest.length} truyện',
                ),
                const SizedBox(height: 10),
                ...latest.map(
                      (comic) => _LatestComicCard(
                    comic: comic,
                    onTap: () => _openDetail(comic),
                    formatCount: _formatCount,
                  ),
                ),

                const SizedBox(height: 18),

                _sectionHeader(
                  title: 'Bảng xếp hạng',
                  icon: Icons.emoji_events_rounded,
                  action: 'Top',
                ),
                const SizedBox(height: 10),
                _rankingBox(topComics),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263756)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _search(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFFD4A02F),
        decoration: InputDecoration(
          hintText: 'Tìm truyện, tác giả, thể loại...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 13.5,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.68),
          ),
          suffixIcon: IconButton(
            onPressed: _search,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFFD4A02F),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroBanner(Comic comic) {
    final imageUrl = comic.bannerImageUrl?.trim().isNotEmpty == true
        ? comic.bannerImageUrl
        : comic.coverImageUrl;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => _openDetail(comic),
        child: Container(
          height: 242,
          decoration: BoxDecoration(
            color: const Color(0xFF10182B),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFF2C3D66)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6574FF).withOpacity(0.16),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _cover(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.02),
                      const Color(0xFF07101F).withOpacity(0.42),
                      const Color(0xFF05070D).withOpacity(0.96),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    _badge('HOT'),
                    const SizedBox(width: 8),
                    _glassChip(
                      Icons.local_fire_department_rounded,
                      'Đang thịnh hành',
                    ),
                    const Spacer(),
                    _glassIcon(Icons.bookmark_border_rounded),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comic.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.06,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comic.summary?.trim().isNotEmpty == true
                          ? comic.summary!
                          : 'Truyện nổi bật đang được cập nhật trong tiên các.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        _infoChip(
                          Icons.menu_book_outlined,
                          '${comic.totalChapters} chap',
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.visibility_outlined,
                          _formatCount(comic.totalViews),
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.favorite_border_rounded,
                          _formatCount(comic.totalFollows),
                        ),
                        const Spacer(),
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFD27A),
                                Color(0xFFD4A02F),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4A02F).withOpacity(0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Đọc ngay',
                                style: TextStyle(
                                  color: Color(0xFF211407),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Color(0xFF211407),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _continueReadingCard(Comic comic) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openDetail(comic),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF172345),
                Color(0xFF10182B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A3A60)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _cover(
                  comic.coverImageUrl,
                  width: 58,
                  height: 76,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 76,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đọc tiếp',
                        style: TextStyle(
                          color: Color(0xFFFFD27A),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comic.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: 0.58,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.12),
                          color: const Color(0xFFD4A02F),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Đang đọc • ${comic.totalChapters} chương',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A02F),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF211407),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final item = categories[index];
          final selected = selectedCategoryIndex == index;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                  colors: [
                    Color(0xFF334CFF),
                    Color(0xFF6574FF),
                  ],
                )
                    : null,
                color: selected ? null : const Color(0xFF10182B),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFBFD0FF)
                      : const Color(0xFF243251),
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF6574FF).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 16,
                    color: selected ? Colors.white : const Color(0xFFBFD0FF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.name,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white.withOpacity(0.78),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _horizontalComicList(List<Comic> comics) {
    if (comics.isEmpty) return _emptyCard('Chưa có truyện đề cử');

    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: comics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final comic = comics[index];

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openDetail(comic),
              child: SizedBox(
                width: 128,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF10182B),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF263756)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.24),
                              blurRadius: 12,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _cover(
                              comic.coverImageUrl,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: _badge(index == 0 ? 'TOP' : 'NEW'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comic.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        height: 1.22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _rankingBox(List<Comic> comics) {
    if (comics.isEmpty) return _emptyCard('Chưa có bảng xếp hạng');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        children: List.generate(comics.length, (index) {
          final comic = comics[index];
          final rank = index + 1;

          return InkWell(
            onTap: () => _openDetail(comic),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              child: Row(
                children: [
                  _rankNumber(rank),
                  const SizedBox(width: 11),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _cover(
                      comic.coverImageUrl,
                      width: 42,
                      height: 52,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comic.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatCount(comic.totalViews)} lượt xem • ${comic.totalChapters} chap',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.46),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _rankNumber(int rank) {
    Color color;

    if (rank == 1) {
      color = const Color(0xFFFFD27A);
    } else if (rank == 2) {
      color = const Color(0xFFC8D3E8);
    } else if (rank == 3) {
      color = const Color(0xFFFF9F6E);
    } else {
      color = Colors.white.withOpacity(0.42);
    }

    return SizedBox(
      width: 28,
      child: Text(
        '$rank',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required IconData icon,
    String? action,
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
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          Row(
            children: [
              Text(
                action,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.52),
                size: 18,
              ),
            ],
          ),
      ],
    );
  }

  Widget _badge(String text) {
    final upper = text.toUpperCase();

    Color start;
    Color end;

    if (upper == 'HOT') {
      start = const Color(0xFFFF4D5B);
      end = const Color(0xFFFF8A3D);
    } else if (upper == 'VIP') {
      start = const Color(0xFF8A5CFF);
      end = const Color(0xFF6574FF);
    } else if (upper == 'TOP') {
      start = const Color(0xFFFFD27A);
      end = const Color(0xFFD4A02F);
    } else {
      start = const Color(0xFF1FA2FF);
      end = const Color(0xFF6574FF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: end.withOpacity(0.28),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        upper,
        style: TextStyle(
          color: upper == 'TOP' ? const Color(0xFF211407) : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFFFFD27A)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIcon(IconData icon) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.26),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _cover(String? url, {double? width, double? height}) {
    if (url != null && url.trim().isNotEmpty) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(width, height),
      );
    }

    return _placeholder(width, height);
  }

  Widget _placeholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF18213A),
            Color(0xFF0E1424),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.menu_book_outlined,
        color: Colors.white54,
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF243251)),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.68)),
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      final result = value / 1000000;
      return '${result.toStringAsFixed(result >= 10 ? 0 : 1)}M';
    }

    if (value >= 1000) {
      final result = value / 1000;
      return '${result.toStringAsFixed(result >= 10 ? 0 : 1)}K';
    }

    return '$value';
  }
}

class _LatestComicCard extends StatelessWidget {
  const _LatestComicCard({
    required this.comic,
    required this.onTap,
    required this.formatCount,
  });

  final Comic comic;
  final VoidCallback onTap;
  final String Function(int value) formatCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF243251)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: _CoverImage(
                    url: comic.coverImageUrl,
                    width: 58,
                    height: 72,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comic.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          comic.authorName?.trim().isNotEmpty == true
                              ? comic.authorName!
                              : 'Đang cập nhật tác giả',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _miniMeta(
                              Icons.menu_book_outlined,
                              '${comic.totalChapters} chap',
                            ),
                            const SizedBox(width: 8),
                            _miniMeta(
                              Icons.visibility_outlined,
                              formatCount(comic.totalViews),
                            ),
                            const SizedBox(width: 8),
                            _miniMeta(
                              Icons.favorite_border_rounded,
                              formatCount(comic.totalFollows),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.46),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _miniMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: Colors.white.withOpacity(0.44),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.48),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.url,
    required this.width,
    required this.height,
  });

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
      child: const Icon(
        Icons.menu_book_outlined,
        color: Colors.white54,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFFFD27A),
          size: 46,
        ),
        const SizedBox(height: 12),
        const Text(
          'Không tải được truyện',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.56),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Thử lại'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD4A02F),
            foregroundColor: const Color(0xFF211407),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.onRetry,
  });

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.menu_book_outlined,
          color: Color(0xFFFFD27A),
          size: 48,
        ),
        const SizedBox(height: 12),
        const Text(
          'Chưa có truyện nào',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Kéo xuống để tải lại hoặc kiểm tra API /comics.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.56),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tải lại'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD4A02F),
            foregroundColor: const Color(0xFF211407),
          ),
        ),
      ],
    );
  }
}

class _ComicCategory {
  final String name;
  final IconData icon;

  const _ComicCategory(this.name, this.icon);
}