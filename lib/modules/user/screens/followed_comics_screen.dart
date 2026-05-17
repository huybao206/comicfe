import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../comic/screens/comic_detail_screen.dart';
import '../model/profile_utility_models.dart';
import '../service/user_service.dart';

class FollowedComicsScreen extends StatefulWidget {
  const FollowedComicsScreen({super.key});

  @override
  State<FollowedComicsScreen> createState() => _FollowedComicsScreenState();
}

class _FollowedComicsScreenState extends State<FollowedComicsScreen> {
  late Future<List<FollowedComicItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<FollowedComicItem>> _load() {
    return context.read<UserService>().getMyFollowedComics();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  void _openComic(FollowedComicItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComicDetailScreen(comicId: item.comicId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        title: const Text('Truyện đang theo dõi'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D0A07),
        foregroundColor: const Color(0xFFF6E7BE),
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: _refresh,
        child: FutureBuilder<List<FollowedComicItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFC7962F)),
              );
            }

            if (snapshot.hasError) {
              return _MessageView(
                icon: Icons.error_outline_rounded,
                title: 'Không tải được danh sách theo dõi',
                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              );
            }

            final items = snapshot.data ?? const <FollowedComicItem>[];
            if (items.isEmpty) {
              return const _MessageView(
                icon: Icons.favorite_border_rounded,
                title: 'Chưa theo dõi truyện nào',
                message: 'Bấm Theo dõi ở trang chi tiết truyện để lưu vào danh sách yêu thích.',
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemBuilder: (context, index) {
                final item = items[index];
                return _FollowedComicCard(
                  item: item,
                  onTap: () => _openComic(item),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
            );
          },
        ),
      ),
    );
  }
}

class _FollowedComicCard extends StatelessWidget {
  const _FollowedComicCard({
    required this.item,
    required this.onTap,
  });

  final FollowedComicItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF17110C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF735624)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 72,
                height: 96,
                color: const Color(0xFF23180F),
                child: item.coverImageUrl != null
                    ? Image.network(
                  item.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFFE0B85C),
                  ),
                )
                    : const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFFE0B85C),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF6E7BE),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TinyInfo(icon: Icons.visibility_outlined, text: '${item.totalViews} lượt xem'),
                      _TinyInfo(icon: Icons.favorite_border_rounded, text: '${item.totalFollows} theo dõi'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.lastReadAt != null
                        ? 'Đọc gần nhất: ${_formatDate(item.lastReadAt)}'
                        : 'Theo dõi từ: ${_formatDate(item.createdAt)}',
                    style: const TextStyle(
                      color: Color(0xFFB89E70),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD2B06D),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyInfo extends StatelessWidget {
  const _TinyInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF23180F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF5E451D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFE0B85C)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Color(0xFFD6BE8A), fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 120, 28, 24),
      children: [
        Icon(icon, size: 54, color: const Color(0xFFE0B85C)),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF6E7BE),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFCCB991),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return 'chưa rõ';
  return "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}";
}
