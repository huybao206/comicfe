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
  final TextEditingController _searchController = TextEditingController();

  int selectedFilterIndex = 0;

  final filters = const [
    _ChatFilter('Tất cả', 'all', Icons.forum_outlined),
    _ChatFilter('Công cộng', 'public', Icons.public_rounded),
    _ChatFilter('Bang của tôi', 'guild', Icons.groups_rounded),
    _ChatFilter('VIP', 'vip', Icons.diamond_outlined),
    _ChatFilter('Hệ thống', 'system', Icons.campaign_outlined),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ChatProvider>().loadRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<ChatRoom> _filteredRooms(List<ChatRoom> rooms) {
    final keyword = _searchController.text.trim().toLowerCase();
    final selected = filters[selectedFilterIndex].value;

    Iterable<ChatRoom> result = rooms;

    if (selected != 'all') {
      result = result.where((room) {
        if (selected == 'public') {
          return room.isPublicRoom;
        }

        return room.roomType == selected;
      });
    }

    if (keyword.isNotEmpty) {
      result = result.where((room) {
        final name = room.displayName.toLowerCase();
        final code = room.roomCode.toLowerCase();
        final desc = room.description?.toLowerCase() ?? '';

        return name.contains(keyword) ||
            code.contains(keyword) ||
            desc.contains(keyword);
      });
    }

    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final rooms = _filteredRooms(provider.rooms);

    final totalMembers = provider.rooms.fold<int>(
      0,
          (sum, room) => sum + room.memberCount,
    );

    final totalMessages = provider.rooms.fold<int>(
      0,
          (sum, room) => sum + room.messageCount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFFD4A02F),
        backgroundColor: const Color(0xFF10182B),
        child: Builder(
          builder: (context) {
            if (provider.isLoadingRooms && provider.rooms.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4A02F),
                ),
              );
            }

            if (provider.errorMessage != null && provider.rooms.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const SizedBox(height: 130),
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
                  SizedBox(height: 130),
                  _EmptyState(),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
              children: [
                _ChatHeroHeader(
                  roomCount: provider.rooms.length,
                  totalMembers: totalMembers,
                  totalMessages: totalMessages,
                ),
                const SizedBox(height: 14),
                _searchBox(),
                const SizedBox(height: 12),
                _filterRow(),
                const SizedBox(height: 18),
                _sectionHeader(
                  title: 'Kênh trò chuyện',
                  action: '${rooms.length} phòng',
                ),
                const SizedBox(height: 11),
                if (rooms.isEmpty)
                  _NoResultState(
                    onClear: () {
                      setState(() {
                        selectedFilterIndex = 0;
                        _searchController.clear();
                      });
                    },
                  )
                else
                  ...rooms.map(
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

  Widget _searchBox() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFFD4A02F),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Tìm phòng chat...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 13.5,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.66),
          ),
          suffixIcon: _searchController.text.trim().isEmpty
              ? const Icon(
            Icons.tune_rounded,
            color: Color(0xFFD4A02F),
          )
              : IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFFD4A02F),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedFilterIndex == index;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                selectedFilterIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                  colors: [
                    Color(0xFFFFD27A),
                    Color(0xFFD4A02F),
                  ],
                )
                    : null,
                color: selected ? null : const Color(0xFF10182B),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFFE9B0)
                      : const Color(0xFF263756),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filter.icon,
                    size: 16,
                    color: selected
                        ? const Color(0xFF211407)
                        : const Color(0xFFBFD0FF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.title,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF211407)
                          : Colors.white.withOpacity(0.78),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
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

  Widget _sectionHeader({
    required String title,
    required String action,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFD4A02F),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 18,
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

class _ChatHeroHeader extends StatelessWidget {
  const _ChatHeroHeader({
    required this.roomCount,
    required this.totalMembers,
    required this.totalMessages,
  });

  final int roomCount;
  final int totalMembers;
  final int totalMessages;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 186,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF7A5A26)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A02F).withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  Color(0xFF3B356D),
                  Color(0xFF172345),
                  Color(0xFF0B1020),
                ],
                stops: [0, 0.46, 1],
              ),
            ),
          ),
          Positioned(
            top: -44,
            right: -34,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6574FF).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -42,
            child: Container(
              width: 146,
              height: 146,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A02F).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            right: 18,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8FB0FF),
                        Color(0xFF6574FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.forum_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cộng đồng tu tiên',
                        style: TextStyle(
                          color: Color(0xFFFFE9B0),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Chọn phòng chat để trò chuyện cùng đạo hữu.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFD7C39A),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: _HeaderStat(
                    icon: Icons.forum_outlined,
                    label: 'Phòng',
                    value: '$roomCount',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderStat(
                    icon: Icons.people_alt_outlined,
                    label: 'Thành viên',
                    value: '$totalMembers',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderStat(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Tin nhắn',
                    value: '$totalMessages',
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

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD27A),
            size: 18,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    height: 1,
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
    final color = _roomColor(room.roomType);
    final icon = _roomIcon(room.roomType);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFF10182B),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withOpacity(0.34)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: color.withOpacity(0.56)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFFFE9B0),
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _RoomTypeBadge(
                            label: room.typeLabel,
                            color: color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        room.description?.trim().isNotEmpty == true
                            ? room.description!
                            : 'Phòng trò chuyện dành cho cộng đồng.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFE9D7AE).withOpacity(0.68),
                          fontSize: 12.5,
                          height: 1.38,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _MiniChip(
                            icon: Icons.people_alt_outlined,
                            text: '${room.memberCount} thành viên',
                          ),
                          _MiniChip(
                            icon: Icons.chat_bubble_outline_rounded,
                            text: '${room.messageCount} tin nhắn',
                          ),
                          _MiniChip(
                            icon: Icons.schedule_rounded,
                            text: room.lastActivityText,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.42),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _roomIcon(String type) {
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

  Color _roomColor(String type) {
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

class _RoomTypeBadge extends StatelessWidget {
  const _RoomTypeBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.42)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF151D31),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF283756)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: Colors.white.withOpacity(0.56),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultState extends StatelessWidget {
  const _NoResultState({
    required this.onClear,
  });

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF10182B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF263756)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: Color(0xFFFFD27A),
            size: 44,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không tìm thấy phòng chat',
            style: TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Thử đổi từ khóa hoặc bỏ bộ lọc hiện tại.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.54),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onClear,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4A02F),
              foregroundColor: const Color(0xFF211407),
            ),
            child: const Text(
              'Bỏ lọc',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
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
            color: Color(0xFFFFE9B0),
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
          'Không tải được phòng chat',
          style: TextStyle(
            color: Color(0xFFFFE9B0),
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
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD4A02F),
            foregroundColor: const Color(0xFF211407),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(
            'Thử lại',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _ChatFilter {
  final String title;
  final String value;
  final IconData icon;

  const _ChatFilter(this.title, this.value, this.icon);
}