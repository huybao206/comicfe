import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../comic/model/chapter.dart';
import '../../comic/service/comic_service.dart';
import '../../comment/widgets/comic_comment_section.dart';
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

enum _ReaderBarPlacement { top, bottom }

class _ReaderScreenState extends State<ReaderScreen> {
  late Future<Chapter> _chapterFuture;
  final ScrollController _scrollController = ScrollController();

  late int _currentChapterId;
  List<Chapter> _chapters = [];
  Chapter? _previousChapter;
  Chapter? _nextChapter;

  bool _showScrollTop = false;
  bool _isChapterReady = false;
  bool _showReaderBar = true;
  _ReaderBarPlacement _barPlacement = _ReaderBarPlacement.bottom;

  @override
  void initState() {
    super.initState();
    _currentChapterId = widget.chapterId;
    _chapterFuture = _loadChapter(_currentChapterId);
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final shouldShow = _scrollController.offset > 500;
    if (shouldShow != _showScrollTop && mounted) {
      setState(() => _showScrollTop = shouldShow);
    }

    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.idle) return;

    // Vuốt xuống: hiện thanh chuyển chương ở dưới như website đọc truyện.
    // Vuốt lên: hiện thanh chuyển chương ở trên như website đọc truyện.
    final nextPlacement = direction == ScrollDirection.forward
        ? _ReaderBarPlacement.bottom
        : _ReaderBarPlacement.top;

    if (!_showReaderBar || _barPlacement != nextPlacement) {
      setState(() {
        _showReaderBar = true;
        _barPlacement = nextPlacement;
      });
    }
  }

  Future<Chapter> _loadChapter(int chapterId) async {
    final service = context.read<ComicService>();
    final chapter = await service.getChapterDetail(chapterId);
    await _loadNeighborChapters(service, chapter);

    try {
      await service.saveReadingProgress(
        chapterId: chapterId,
        lastPageNumber: 1,
      );
    } catch (_) {}

    if (mounted && chapterId == _currentChapterId) {
      setState(() => _isChapterReady = true);
    }

    return chapter;
  }

  Future<void> _loadNeighborChapters(
      ComicService service,
      Chapter chapter,
      ) async {
    try {
      final chapters = await service.getChaptersByComic(chapter.comicId);
      final publishedChapters = chapters.where((item) => item.id > 0).toList()
        ..sort((a, b) {
          final numberCompare = a.chapterNumber.compareTo(b.chapterNumber);
          if (numberCompare != 0) return numberCompare;
          return a.id.compareTo(b.id);
        });

      final currentIndex = publishedChapters.indexWhere(
            (item) => item.id == chapter.id,
      );

      if (currentIndex == -1) {
        _chapters = publishedChapters;
        _previousChapter = null;
        _nextChapter = null;
        return;
      }

      _chapters = publishedChapters;
      _previousChapter = currentIndex > 0
          ? publishedChapters[currentIndex - 1]
          : null;
      _nextChapter = currentIndex < publishedChapters.length - 1
          ? publishedChapters[currentIndex + 1]
          : null;
    } catch (_) {
      _chapters = [];
      _previousChapter = null;
      _nextChapter = null;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isChapterReady = false;
      _chapterFuture = _loadChapter(_currentChapterId);
    });
    await _chapterFuture;
  }

  void _openChapter(int chapterId) {
    if (chapterId == _currentChapterId) return;

    setState(() {
      _currentChapterId = chapterId;
      _previousChapter = null;
      _nextChapter = null;
      _isChapterReady = false;
      _showScrollTop = false;
      _showReaderBar = true;
      _barPlacement = _ReaderBarPlacement.bottom;
      _chapterFuture = _loadChapter(chapterId);
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  String _formatChapterNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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

          return Stack(
            children: [
              RefreshIndicator(
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
                            return ColoredBox(
                              color: Colors.black,
                              child: ImageViewer(imageUrl: image.imageUrl),
                            );
                          },
                          childCount: chapter.images.length,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: ChapterCommentSection(
                        key: ValueKey<int>(chapter.id),
                        chapterId: chapter.id,
                        chapterLabel:
                        'Chương ${_formatChapterNumber(chapter.chapterNumber)}: ${chapter.title}',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _chapterFooter(),
                    ),
                  ],
                ),
              ),
              if (_showReaderBar)
                Positioned(
                  left: 0,
                  right: 0,
                  top: _barPlacement == _ReaderBarPlacement.top ? 0 : null,
                  bottom:
                  _barPlacement == _ReaderBarPlacement.bottom ? 0 : null,
                  child: SafeArea(
                    top: _barPlacement == _ReaderBarPlacement.top,
                    bottom: _barPlacement == _ReaderBarPlacement.bottom,
                    child: _chapterNavigationBar(chapter),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _chapterNavigationBar(Chapter chapter) {
    return Material(
      color: Colors.white.withOpacity(0.94),
      elevation: 10,
      child: SizedBox(
        height: 46,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Quay lại',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.home_rounded, color: Color(0xFFE85757)),
            ),
            IconButton(
              tooltip: 'Chương trước',
              onPressed: _previousChapter == null
                  ? null
                  : () => _openChapter(_previousChapter!.id),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: PopupMenuButton<int>(
                enabled: _isChapterReady && _chapters.isNotEmpty,
                onSelected: _openChapter,
                constraints: const BoxConstraints(maxHeight: 360),
                itemBuilder: (context) {
                  return _chapters.map((item) {
                    final isCurrent = item.id == _currentChapterId;
                    return PopupMenuItem<int>(
                      value: item.id,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Chapter ${_formatChapterNumber(item.chapterNumber)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isCurrent
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Color(0xFFE85757),
                            ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: const Color(0xFFD7D7D7)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chapter ${_formatChapterNumber(chapter.chapterNumber)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Chương tiếp',
              onPressed: _nextChapter == null
                  ? null
                  : () => _openChapter(_nextChapter!.id),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _chapterHeader(Chapter chapter) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151B2D), Color(0xFF10192E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF263454)),
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
            'Chương ${_formatChapterNumber(chapter.chapterNumber)}: ${chapter.title}',
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
              _miniInfo(Icons.visibility_outlined, '${chapter.viewCount} lượt xem'),
              const SizedBox(width: 8),
              _miniInfo(Icons.image_outlined, '${chapter.images.length} ảnh'),
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
        border: Border.all(color: const Color(0xFF5B8CFF).withOpacity(0.55)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 15, color: Color(0xFF8FB0FF)),
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
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
    final hasPreviousChapter = _previousChapter != null;
    final hasNextChapter = _nextChapter != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 14, 12, 72),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263454)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8FB0FF)),
          const SizedBox(height: 8),
          Text(
            'Hết chương',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasPreviousChapter
                      ? () => _openChapter(_previousChapter!.id)
                      : null,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  label: const Text('Trước'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.18)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: hasNextChapter
                      ? () => _openChapter(_nextChapter!.id)
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  label: const Text('Tiếp'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8CFF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withOpacity(0.08),
                    disabledForegroundColor: Colors.white.withOpacity(0.34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() {
              _showReaderBar = true;
              _barPlacement = _ReaderBarPlacement.bottom;
            }),
            icon: const Icon(Icons.swap_vert_rounded),
            label: const Text('Hiện thanh chuyển chương'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFBFD0FF)),
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
