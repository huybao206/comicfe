import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/chat_room.dart';
import '../provider/chat_provider.dart';
import 'chat_screen.dart';

class ChatRoomListScreen extends StatefulWidget {
  const ChatRoomListScreen({super.key});

  @override
  State<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ChatProvider>().loadRooms();
    });
  }

  Future<void> _refresh() async {
    await context.read<ChatProvider>().loadRooms();
  }

  Future<void> _openRoom(ChatRoom room) async {
    await context.read<ChatProvider>().openRoom(room);

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF6574FF),
        child: Builder(
          builder: (context) {
            if (provider.isLoadingRooms && provider.rooms.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6574FF),
                ),
              );
            }

            if (provider.errorMessage != null && provider.rooms.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const SizedBox(height: 120),
                  _ErrorState(
                    message: provider.errorMessage!,
                    onRetry: _refresh,
                  ),
                ],
              );
            }

            if (provider.rooms.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(18),
                children: const [
                  SizedBox(height: 120),
                  _EmptyState(),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              children: [
                _Header(roomCount: provider.rooms.length),
                const SizedBox(height: 14),
                ...provider.rooms.map(
                      (room) => _RoomCard(
                    room: room,
                    onTap: () => _openRoom(room),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.roomCount,
  });

  final int roomCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF172345),
            Color(0xFF10182B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF253251)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF6574FF).withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6574FF)),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: Color(0xFFBFD0FF),
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phòng chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$roomCount phòng đang mở. Chọn phòng để trò chuyện.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
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

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.onTap,
  });

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = _iconByType(room.roomType);
    final color = _colorByType(room.roomType);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: const Color(0xFF0E1424),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF222E4C)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.65)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room.description?.trim().isNotEmpty == true
                            ? room.description!
                            : room.typeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.52),
                          fontSize: 12.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        runSpacing: 6,
                        children: [
                          _smallBadge(
                            icon: Icons.people_alt_outlined,
                            text: '${room.memberCount} thành viên',
                          ),
                          _smallBadge(
                            icon: Icons.chat_bubble_outline_rounded,
                            text: '${room.messageCount} tin nhắn',
                          ),
                          _smallBadge(
                            icon: Icons.circle,
                            text: room.isActive ? 'Hoạt động' : 'Đã ẩn',
                            active: room.isActive,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8FA1C7),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallBadge({
    required IconData icon,
    required String text,
    bool active = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF1E8E4F).withOpacity(0.16)
            : const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? const Color(0xFF4ADE80).withOpacity(0.5)
              : const Color(0xFF283251),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: icon == Icons.circle ? 7 : 13,
            color: active
                ? const Color(0xFF86EFAC)
                : Colors.white.withOpacity(0.55),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: active
                  ? const Color(0xFFBBF7D0)
                  : Colors.white.withOpacity(0.58),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconByType(String type) {
    switch (type) {
      case 'guild':
        return Icons.groups_rounded;
      case 'vip':
        return Icons.diamond_rounded;
      case 'system':
        return Icons.campaign_rounded;
      default:
        return Icons.public_rounded;
    }
  }

  Color _colorByType(String type) {
    switch (type) {
      case 'guild':
        return const Color(0xFF4ADE80);
      case 'vip':
        return const Color(0xFFFFD27A);
      case 'system':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF8FB0FF);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.forum_outlined,
          color: Colors.white.withOpacity(0.28),
          size: 46,
        ),
        const SizedBox(height: 12),
        const Text(
          'Chưa có phòng chat nào',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hãy tạo phòng chat trong admin trước.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
          'Không tải được phòng chat',
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
            color: Colors.white.withOpacity(0.55),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Thử lại'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6574FF),
          ),
        ),
      ],
    );
  }
}