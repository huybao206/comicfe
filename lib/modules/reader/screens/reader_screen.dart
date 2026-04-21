import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../comic/model/chapter.dart';
import '../../comic/service/comic_service.dart';
import '../widgets/image_viewer.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    super.key,
    required this.chapterId,
  });

  final int chapterId;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Future<Chapter> _chapterFuture;
  final ScrollController _scrollController = ScrollController();

  bool _showScrollTop = false;

  @override
  void initState() {
    super.initState();
    _chapterFuture = _loadChapter();

    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 500;
      if (shouldShow != _showScrollTop) {
        setState(() {
          _showScrollTop = shouldShow;
        });
      }
    });
  }

  Future<Chapter> _loadChapter() {
    return context.read<ComicService>().getChapterDetail(widget.chapterId);
  }

  Future<void> _refresh() async {
    setState(() {
      _chapterFuture = _loadChapter();
    });
    await _chapterFuture;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text(
          'Đọc truyện',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF070B14),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: _showScrollTop
          ? FloatingActionButton.small(
        backgroundColor: const Color(0xFF5B8CFF),
        foregroundColor: Colors.white,
        onPressed: _scrollToTop,
        child: const Icon(Icons.keyboard_arrow_up_rounded),
      )
          : null,
      body: FutureBuilder<Chapter>(
        future: _chapterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B8CFF)),
            );
          }

          if (snapshot.hasError) {
            return _errorView(
              snapshot.error.toString().replaceFirst('Exception: ', ''),
            );
          }

          if (!snapshot.hasData) {
            return _errorView('Không có dữ liệu chapter');
          }

          final chapter = snapshot.data!;

          return RefreshIndicator(
            color: const Color(0xFF5B8CFF),
            backgroundColor: const Color(0xFF151B2D),
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _chapterHeader(chapter),
                ),
                if (chapter.images.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Chapter này chưa có ảnh',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final image = chapter.images[index];

                        return Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E1320),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1F2A44),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ImageViewer(
                              imageUrl: image.imageUrl,
                            ),
                          ),
                        );
                      },
                      childCount: chapter.images.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _chapterFooter(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chapterHeader(Chapter chapter) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF151B2D),
            Color(0xFF10192E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF263454),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _realmBadge(),
          const SizedBox(height: 12),
          Text(
            chapter.comicTitle ?? 'Truyện tu tiên',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chương ${chapter.chapterNumber}: ${chapter.title}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _miniInfo(
                Icons.visibility_outlined,
                '${chapter.viewCount} lượt xem',
              ),
              const SizedBox(width: 8),
              _miniInfo(
                Icons.image_outlined,
                '${chapter.images.length} ảnh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _realmBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF5B8CFF).withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF5B8CFF).withOpacity(0.55),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 15,
            color: Color(0xFF8FB0FF),
          ),
          SizedBox(width: 6),
          Text(
            'Đang đọc chương',
            style: TextStyle(
              color: Color(0xFFBFD0FF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chapterFooter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263454)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF8FB0FF),
          ),
          const SizedBox(height: 8),
          Text(
            'Hết chương',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy quay lại danh sách chapter để đọc tiếp.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF151B2D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF263454)),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}