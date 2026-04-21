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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phòng chat'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ChatProvider>().loadRooms(),
        child: Builder(
          builder: (context) {
            if (provider.isLoadingRooms && provider.rooms.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null && provider.rooms.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(provider.errorMessage!)),
                ],
              );
            }

            if (provider.rooms.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Chưa có phòng chat')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: provider.rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final room = provider.rooms[index];
                return _roomCard(room);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _roomCard(ChatRoom room) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            room.roomType == 'guild' ? Icons.groups : Icons.chat_bubble_outline,
          ),
        ),
        title: Text(room.roomName),
        subtitle: Text(
          '${room.description ?? "Không có mô tả"}\n'
              'Loại: ${room.roomType} • Thành viên: ${room.memberCount}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await context.read<ChatProvider>().openRoom(room);
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ChatScreen(),
            ),
          );
        },
      ),
    );
  }
}