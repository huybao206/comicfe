import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/comment_item.dart';
import '../provider/comment_provider.dart';

class ComicCommentSection extends StatefulWidget {
  const ComicCommentSection({
    super.key,
    required this.comicId,
  });

  final int comicId;

  @override
  State<ComicCommentSection> createState() => _ComicCommentSectionState();
}

class _ComicCommentSectionState extends State<ComicCommentSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CommentProvider>().loadComicComments(widget.comicId);
    });
  }

  @override
  void didUpdateWidget(covariant ComicCommentSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.comicId != widget.comicId) {
      Future.microtask(() {
        context.read<CommentProvider>().loadComicComments(widget.comicId);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final provider = context.read<CommentProvider>();
    final text = _controller.text.trim();

    final ok = await provider.createComicComment(
      comicId: widget.comicId,
      content: text,
    );

    if (!mounted) return;

    if (ok) {
      _controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2F6B3B),
          content: Text('Đã gửi bình luận'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(provider.errorMessage ?? 'Không gửi được bình luận'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();
    final comments = provider.commentsOfComic(widget.comicId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1424),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF222E4C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Bình luận'),
          const SizedBox(height: 12),
          _inputBox(provider),
          const SizedBox(height: 14),
          if (provider.isLoading && comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF5B8CFF)),
              ),
            )
          else if (provider.errorMessage != null && comments.isEmpty)
            _errorBox(provider.errorMessage!)
          else if (comments.isEmpty)
              _emptyBox()
            else
              ...comments.map(_commentTile),
        ],
      ),
    );
  }

  Widget _inputBox(CommentProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2340),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF283251)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              maxLength: 1000,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Viết bình luận...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.42)),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            height: 42,
            child: FilledButton(
              onPressed: provider.isSubmitting ? null : _submitComment,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFF6574FF),
                disabledBackgroundColor: const Color(0xFF2A3146),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: provider.isSubmitting
                  ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentTile(CommentItem comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(comment),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _commentBubble(comment),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...comment.replies.map(_replyTile),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyTile(CommentItem reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(reply, radius: 14),
          const SizedBox(width: 8),
          Expanded(
            child: _commentBubble(reply, isReply: true),
          ),
        ],
      ),
    );
  }

  Widget _commentBubble(CommentItem comment, {bool isReply = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isReply ? const Color(0xFF11192C) : const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isReply ? const Color(0xFF202B49) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${comment.displayName} • ${_formatTime(comment.createdAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBFD0FF),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (comment.chapterId != null) ...[
            const SizedBox(height: 6),
            _chapterBadge(comment),
          ],
          const SizedBox(height: 6),
          Text(
            _displayContent(comment),
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12.8,
              height: 1.38,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.42),
              ),
              const SizedBox(width: 4),
              Text(
                '${comment.likeCount}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.42),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _chapterBadge(CommentItem comment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF202B49),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF354777)),
      ),
      child: Text(
        _chapterLabel(comment),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withOpacity(0.72),
          fontSize: 11.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _chapterLabel(CommentItem comment) {
    if (comment.chapterTitle != null && comment.chapterTitle!.isNotEmpty) {
      return 'Bình luận tại ${comment.chapterTitle}';
    }

    final number = comment.chapterNumber;
    if (number != null) {
      return 'Bình luận tại Chapter ${number.toString()}';
    }

    return 'Bình luận tại chương';
  }

  String _displayContent(CommentItem comment) {
    final text = comment.content.trim();
    if (text.isEmpty) return '(Bình luận không có nội dung)';
    return text;
  }

  Widget _avatar(CommentItem comment, {double radius = 17}) {
    if (comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF6574FF),
        backgroundImage: NetworkImage(comment.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF6574FF),
      child: Icon(
        Icons.person,
        size: radius,
        color: Colors.white,
      ),
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

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF351D26),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7A2E2E)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  Widget _emptyBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF11182A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222E4C)),
      ),
      child: Text(
        'Chưa có bình luận nào. Hãy là người đầu tiên bình luận bộ truyện này.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value);

    if (diff.inMinutes < 1) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();

    return '$day/$month/$year';
  }
}

// Chapter-specific comments are kept in this same file to match the original project structure.
class ChapterCommentSection extends StatefulWidget {
  const ChapterCommentSection({
    super.key,
    required this.chapterId,
    this.chapterLabel,
  });

  final int chapterId;
  final String? chapterLabel;

  @override
  State<ChapterCommentSection> createState() => _ChapterCommentSectionState();
}

class _ChapterCommentSectionState extends State<ChapterCommentSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<CommentProvider>().loadChapterComments(widget.chapterId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChapterCommentSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chapterId != widget.chapterId) {
      _controller.clear();
      Future.microtask(() {
        if (mounted) {
          context.read<CommentProvider>().loadChapterComments(widget.chapterId);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final provider = context.read<CommentProvider>();
    final text = _controller.text.trim();

    final ok = await provider.createChapterComment(
      chapterId: widget.chapterId,
      content: text,
    );

    if (!mounted) return;

    if (ok) {
      _controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2F6B3B),
          content: Text('Đã gửi bình luận chương'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A2E2E),
          content: Text(provider.errorMessage ?? 'Không gửi được bình luận'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();
    final comments = provider.commentsOfChapter(widget.chapterId);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1424),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF222E4C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(),
          if (widget.chapterLabel != null && widget.chapterLabel!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              widget.chapterLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.52),
                fontSize: 12.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _inputBox(provider),
          const SizedBox(height: 14),
          if (provider.isLoading && comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF5B8CFF)),
              ),
            )
          else if (provider.errorMessage != null && comments.isEmpty)
            _errorBox(provider.errorMessage!)
          else if (comments.isEmpty)
              _emptyBox()
            else
              ...comments.map(_commentTile),
        ],
      ),
    );
  }

  Widget _inputBox(CommentProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2340),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF283251)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              maxLength: 1000,
              enabled: !provider.isSubmitting,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Viết bình luận cho chương này...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.42)),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => provider.isSubmitting ? null : _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            height: 42,
            child: FilledButton(
              onPressed: provider.isSubmitting ? null : _submitComment,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFF6574FF),
                disabledBackgroundColor: const Color(0xFF2A3146),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: provider.isSubmitting
                  ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentTile(CommentItem comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(comment),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _commentBubble(comment),
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...comment.replies.map(_replyTile),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyTile(CommentItem reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(reply, radius: 14),
          const SizedBox(width: 8),
          Expanded(child: _commentBubble(reply, isReply: true)),
        ],
      ),
    );
  }

  Widget _commentBubble(CommentItem comment, {bool isReply = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isReply ? const Color(0xFF11192C) : const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isReply ? const Color(0xFF202B49) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${comment.displayName} • ${_formatTime(comment.createdAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBFD0FF),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _displayContent(comment),
            style: TextStyle(
              color: Colors.white.withOpacity(0.84),
              fontSize: 12.8,
              height: 1.38,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.42),
              ),
              const SizedBox(width: 4),
              Text(
                '${comment.likeCount}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.42),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  String _displayContent(CommentItem comment) {
    final text = comment.content.trim();
    if (text.isEmpty) return '(Bình luận không có nội dung)';
    return text;
  }

  Widget _avatar(CommentItem comment, {double radius = 17}) {
    if (comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF6574FF),
        backgroundImage: NetworkImage(comment.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF6574FF),
      child: Icon(
        Icons.person,
        size: radius,
        color: Colors.white,
      ),
    );
  }

  Widget _sectionTitle() {
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
        const Expanded(
          child: Text(
            'Bình luận chương',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF351D26),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7A2E2E)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  Widget _emptyBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF11182A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222E4C)),
      ),
      child: Text(
        'Chưa có bình luận nào cho chương này. Hãy là người đầu tiên bình luận.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value);

    if (diff.inMinutes < 1) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();

    return '$day/$month/$year';
  }
}
