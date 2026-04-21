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

  void _search() {
    context.read<ComicProvider>().loadComics(
      keyword: _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComicProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1320),
      body: RefreshIndicator(
        color: const Color(0xFF5B8CFF),
        backgroundColor: const Color(0xFF151B2D),
        onRefresh: () => context.read<ComicProvider>().loadComics(
          keyword: _searchController.text.trim(),
        ),
        child: Builder(
          builder: (context) {
            if (provider.isLoading && provider.comics.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5B8CFF),
                ),
              );
            }

            if (provider.errorMessage != null && provider.comics.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 160),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              );
            }

            final comics = provider.comics;
            final featured = comics.take(6).toList();
            final latest = comics.take(8).toList();
            final hot = comics.length > 6 ? comics.skip(1).take(9).toList() : comics;

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                _searchBox(),
                const SizedBox(height: 14),
                if (featured.isNotEmpty) _heroBanner(featured.first),
                const SizedBox(height: 18),
                _sectionHeader('Phân Loại', 'Xem thêm'),
                const SizedBox(height: 10),
                _categoryRow(),
                const SizedBox(height: 18),
                _sectionHeader('Mới Cập Nhật', 'Xem thêm'),
                const SizedBox(height: 10),
                _latestSection(latest),
                const SizedBox(height: 18),
                _sectionHeader('Bảng Xếp Hạng Đề Cử', null),
                const SizedBox(height: 10),
                _rankingSection(featured),
                const SizedBox(height: 18),
                _sectionHeader('Truyện hot 🔥', 'Xem thêm'),
                const SizedBox(height: 10),
                _hotGrid(hot),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF232B44)),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _search(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm truyện...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
          suffixIcon: IconButton(
            onPressed: _search,
            icon: const Icon(Icons.arrow_forward, color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _heroBanner(Comic comic) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openDetail(comic),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: const Color(0xFF151B2D),
          borderRadius: BorderRadius.circular(18),
          image: comic.coverImageUrl != null && comic.coverImageUrl!.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(comic.coverImageUrl!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.38),
              BlendMode.darken,
            ),
          )
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.78),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _badge('HOT'),
              const Spacer(),
              Text(
                comic.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                comic.summary?.isNotEmpty == true
                    ? comic.summary!
                    : 'Truyện nổi bật đang được cập nhật.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _infoChip(Icons.menu_book_outlined, '${comic.totalChapters} chap'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.visibility_outlined, '${comic.totalViews}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryRow() {
    final items = [
      ('Romance', Icons.favorite_outline),
      ('Comedy', Icons.sentiment_satisfied_alt),
      ('Action', Icons.local_fire_department_outlined),
      ('Fantasy', Icons.auto_awesome_outlined),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF151B2D),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF232B44)),
            ),
            child: Row(
              children: [
                Icon(item.$2, size: 16, color: const Color(0xFF5B8CFF)),
                const SizedBox(width: 6),
                Text(
                  item.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _latestSection(List<Comic> comics) {
    if (comics.isEmpty) return _emptyCard('Chưa có truyện mới');

    return Column(
      children: comics.map((comic) {
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openDetail(comic),
          child: Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF151B2D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF232B44)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: _cover(comic.coverImageUrl, width: 48, height: 58),
                ),
                const SizedBox(width: 10),
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        comic.authorName?.isNotEmpty == true
                            ? comic.authorName!
                            : 'Đang cập nhật',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.58),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'chapter ${comic.totalChapters}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _rankingSection(List<Comic> comics) {
    if (comics.isEmpty) return _emptyCard('Chưa có dữ liệu xếp hạng');

    final top = comics.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF232B44)),
      ),
      child: Column(
        children: List.generate(top.length, (index) {
          final comic = top[index];
          final rank = index + 1;

          return ListTile(
            dense: true,
            onTap: () => _openDetail(comic),
            leading: Text(
              '$rank',
              style: TextStyle(
                color: rank == 1
                    ? Colors.amber
                    : rank == 2
                    ? Colors.white70
                    : rank == 3
                    ? Colors.orangeAccent
                    : Colors.white54,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            title: Text(
              comic.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Text(
              '${comic.totalViews}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 12,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _hotGrid(List<Comic> comics) {
    if (comics.isEmpty) return _emptyCard('Chưa có truyện hot');

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
        childAspectRatio: 0.56,
      ),
      itemBuilder: (context, index) {
        final comic = comics[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openDetail(comic),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _cover(
                        comic.coverImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _badge(index % 3 == 0 ? 'HOT' : index % 3 == 1 ? 'NEW' : 'VIP'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                comic.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, String? action) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF5B8CFF),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          Row(
            children: [
              Text(
                action,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 12,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.62),
                size: 18,
              ),
            ],
          ),
      ],
    );
  }

  Widget _badge(String text) {
    final upper = text.toUpperCase();
    final color = upper == 'HOT'
        ? const Color(0xFFFF4D5B)
        : upper == 'VIP'
        ? const Color(0xFF8A5CFF)
        : const Color(0xFF1FA2FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        upper,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cover(String? url, {double? width, double? height}) {
    if (url != null && url.isNotEmpty) {
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
      color: const Color(0xFF1F2740),
      child: const Icon(Icons.menu_book_outlined, color: Colors.white54),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF232B44)),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  void _openDetail(Comic comic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComicDetailScreen(comicId: comic.id),
      ),
    );
  }
}