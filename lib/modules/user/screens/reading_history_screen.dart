import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../reader/screens/reader_screen.dart';
import '../model/profile_utility_models.dart';
import '../service/user_service.dart';

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  late Future<List<ReadingHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ReadingHistoryItem>> _load() {
    return context.read<UserService>().getMyReadingHistory(limit: 100);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  void _openReader(ReadingHistoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReaderScreen(chapterId: item.chapterId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A07),
      appBar: AppBar(
        title: const Text('Lịch sử đọc'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D0A07),
        foregroundColor: const Color(0xFFF6E7BE),
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC7962F),
        backgroundColor: const Color(0xFF1A130D),
        onRefresh: _refresh,
        child: FutureBuilder<List<ReadingHistoryItem>>(
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
                title: 'Không tải được lịch sử đọc',
                message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              );
            }

            final items = snapshot.data ?? const <ReadingHistoryItem>[];
            if (items.isEmpty) {
              return const _MessageView(
                icon: Icons.history_rounded,
                title: 'Chưa có lịch sử đọc',
                message: 'Khi bạn mở chapter, truyện sẽ xuất hiện ở đây để đọc tiếp nhanh hơn.',
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemBuilder: (context, index) {
                final item = items[index];
                return _HistoryCard(
                  item: item,
                  onTap: () => _openReader(item),
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.onTap,
  });

  final ReadingHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chapterLabel = item.chapterNumber > 0
        ? 'Chapter ${_formatNumber(item.chapterNumber)}'
        : 'Chapter';
    final progress = item.progressPercent.clamp(0, 100).toDouble();

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
                width: 70,
                height: 92,
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
                    item.comicTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF6E7BE),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$chapterLabel • ${item.chapterTitle.isEmpty ? 'Đang đọc' : item.chapterTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFD6BE8A),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: progress <= 0 ? 0 : progress / 100,
                      backgroundColor: const Color(0xFF2B2115),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC7962F)),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    progress > 0
                        ? 'Đã đọc ${progress.toStringAsFixed(0)}% • ${_formatDate(item.lastReadAt)}'
                        : 'Đọc gần nhất: ${_formatDate(item.lastReadAt)}',
                    style: const TextStyle(
                      color: Color(0xFFB89E70),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatDate(DateTime? value) {
  if (value == null) return 'chưa rõ';
  return "${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}";
}
