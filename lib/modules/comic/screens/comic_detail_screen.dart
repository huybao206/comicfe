import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../reader/screens/reader_screen.dart';
import '../provider/comic_provider.dart';

class ComicDetailScreen extends StatefulWidget {
  const ComicDetailScreen({
    super.key,
    required this.comicId,
  });

  final int comicId;

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ComicProvider>().loadComicDetail(widget.comicId);
    });
  }

  Future<void> _toggleFollow() async {
    final provider = context.read<ComicProvider>();
    final ok = await provider.toggleFollowComic(widget.comicId);

    if (!mounted) return;

    final isFollowing = provider.isComicFollowed(widget.comicId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        ok ? const Color(0xFF2F6B3B) : const Color(0xFF7A2E2E),
        content: Text(
          ok
              ? (isFollowing
              ? 'Đã thêm truyện vào danh sách theo dõi'
              : 'Đã bỏ theo dõi truyện')
              : (provider.errorMessage ?? 'Không thể cập nhật theo dõi'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComicProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text(
          'Truyện',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF070B14),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Builder(
        builder: (_) {
          if (provider.isLoading && provider.selectedComic == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B8CFF)),
            );
          }

          if (provider.selectedComic == null) {
            return Center(
              child: Text(
                provider.errorMessage ?? 'Không có dữ liệu truyện',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          final comic = provider.selectedComic!;
          final isFollowing = provider.isComicFollowed(widget.comicId);

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
            children: [
              _coverHero(comic),
              const SizedBox(height: 14),
              _titleBlock(comic),
              const SizedBox(height: 12),
              _statsBlock(comic),
              const SizedBox(height: 12),
              _actionButtons(context, provider, isFollowing),
              const SizedBox(height: 16),
              _infoBlock(comic),
              const SizedBox(height: 16),
              _introBlock(comic),
              const SizedBox(height: 16),
              _chapterBlock(context, provider),
              const SizedBox(height: 16),
              _commentBlock(),
            ],
          );
        },
      ),
    );
  }

  Widget _coverHero(dynamic comic) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 250,
        color: const Color(0xFF151B2D),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (comic.coverImageUrl != null &&
                comic.coverImageUrl.toString().isNotEmpty)
              Image.network(
                comic.coverImageUrl.toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _coverPlaceholder(),
              )
            else
              _coverPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.75),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _badge('HOT'),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Text(
                comic.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleBlock(dynamic comic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comic.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          comic.authorName?.toString().isNotEmpty == true
              ? comic.authorName.toString()
              : 'Đang cập nhật tác giả',
          style: TextStyle(
            color: Colors.white.withOpacity(0.62),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _statsBlock(dynamic comic) {
    return Row(
      children: [
        Expanded(
          child: _statItem('${comic.totalViews}', 'Lượt xem'),
        ),
        Expanded(
          child: _statItem('${comic.totalChapters}', 'Chapter'),
        ),
        Expanded(
          child: _statItem('${comic.totalFollows}', 'Theo dõi'),
        ),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF253251)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(
      BuildContext context,
      ComicProvider provider,
      bool isFollowing,
      ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: provider.chapters.isEmpty
                ? null
                : () {
              final first = provider.chapters.first;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReaderScreen(chapterId: first.id),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6574FF),
              disabledBackgroundColor: const Color(0xFF2A3146),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Đọc từ đầu',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: provider.isFollowingSubmitting ? null : _toggleFollow,
            icon: Icon(
              isFollowing ? Icons.bookmark_rounded : Icons.bookmark_border,
            ),
            label: Text(isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
              isFollowing ? const Color(0xFF1A2342) : Colors.transparent,
              side: BorderSide(
                color: isFollowing
                    ? const Color(0xFF6574FF)
                    : const Color(0xFF253251),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBlock(dynamic comic) {
    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Thông tin truyện'),
          const SizedBox(height: 12),
          _infoRow('Tác giả', comic.authorName ?? 'Đang cập nhật'),
          _infoRow('Trạng thái', comic.publicationStatus ?? 'Đang cập nhật'),
          _infoRow('Độ tuổi', comic.ageRating ?? 'Không rõ'),
          _infoRow('Thể loại', comic.genres ?? 'Đang cập nhật'),
        ],
      ),
    );
  }

  Widget _introBlock(dynamic comic) {
    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Giới thiệu'),
          const SizedBox(height: 12),
          Text(
            comic.summary?.toString().isNotEmpty == true
                ? comic.summary.toString()
                : 'Chưa có mô tả cho bộ truyện này.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              height: 1.55,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chapterBlock(BuildContext context, ComicProvider provider) {
    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Danh sách chương'),
          const SizedBox(height: 12),
          if (provider.chapters.isEmpty)
            Text(
              'Chưa có chapter nào',
              style: TextStyle(color: Colors.white.withOpacity(0.65)),
            )
          else
            ...provider.chapters.map(
                  (chapter) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111B31),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF24304E)),
                ),
                child: ListTile(
                  dense: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReaderScreen(chapterId: chapter.id),
                      ),
                    );
                  },
                  title: Text(
                    'Chapter ${chapter.chapterNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    chapter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.55)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Colors.white.withOpacity(0.45),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${chapter.viewCount}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _commentBlock() {
    return _darkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Bình luận'),
          const SizedBox(height: 12),
          Container(
            height: 86,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2340),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF283251)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Viết bình luận...',
                    style: TextStyle(color: Colors.white.withOpacity(0.45)),
                  ),
                ),
                const Icon(Icons.send_rounded, color: Color(0xFF8FB0FF)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _fakeComment('Loy', 'Chapter 25', 'Cốt ổn, nhân vật chính khá cuốn.'),
          _fakeComment(
            'Loy',
            'Chapter 24',
            'Truyện thuộc kiểu tu tiên đọc khá ổn.',
          ),
        ],
      ),
    );
  }

  Widget _darkCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1424),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF222E4C)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF6574FF),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.48),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeComment(String name, String chapter, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFF6574FF),
            child: Icon(Icons.person, size: 17, color: Colors.white),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF151B2D),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name • $chapter',
                    style: const TextStyle(
                      color: Color(0xFFBFD0FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D5B),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: const Color(0xFF151B2D),
      child: const Icon(
        Icons.menu_book_outlined,
        color: Colors.white54,
        size: 40,
      ),
    );
  }
}