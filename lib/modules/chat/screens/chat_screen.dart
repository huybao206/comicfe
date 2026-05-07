import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/message.dart';
import '../provider/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(_scrollToBottom);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final provider = context.read<ChatProvider>();
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    final ok = await provider.sendMessage(text);

    if (!mounted) return;

    if (ok) {
      _messageController.clear();
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF8B2F2F),
          content: Text(provider.errorMessage ?? 'Không gửi được tin nhắn'),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    await context.read<ChatProvider>().refreshMessages();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final room = provider.selectedRoom;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6574FF).withOpacity(0.18),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _roomIcon(room?.roomType ?? 'public'),
                color: const Color(0xFFBFD0FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room?.displayName ?? 'Phòng chat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room?.typeLabel ?? 'Chat cộng đồng',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.48),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messageBody(provider),
          ),
          _inputBar(provider),
        ],
      ),
    );
  }

  Widget _messageBody(ChatProvider provider) {
    if (provider.selectedRoom == null) {
      return _emptyState(
        icon: Icons.forum_outlined,
        title: 'Chưa chọn phòng chat',
        subtitle: 'Quay lại danh sách phòng và chọn một phòng để trò chuyện.',
      );
    }

    if (provider.isLoadingMessages && provider.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6574FF),
        ),
      );
    }

    if (provider.errorMessage != null && provider.messages.isEmpty) {
      return _emptyState(
        icon: Icons.error_outline_rounded,
        title: 'Không tải được tin nhắn',
        subtitle: provider.errorMessage!,
      );
    }

    if (provider.messages.isEmpty) {
      return _emptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Chưa có tin nhắn nào',
        subtitle: 'Hãy là người đầu tiên mở lời trong phòng này.',
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFF6574FF),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        itemCount: provider.messages.length,
        itemBuilder: (context, index) {
          final message = provider.messages[index];

          return _MessageBubble(message: message);
        },
      ),
    );
  }

  Widget _inputBar(ChatProvider provider) {
    final canSend = provider.selectedRoom != null && !provider.isSending;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1020),
        border: Border(
          top: BorderSide(color: Color(0xFF1E2A44)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 46,
                  maxHeight: 110,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF11182A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A3758)),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  enabled: canSend,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: canSend ? 'Nhập tin nhắn...' : 'Chưa chọn phòng',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.42),
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              height: 48,
              child: FilledButton(
                onPressed: canSend ? _sendMessage : null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFF6574FF),
                  disabledBackgroundColor: const Color(0xFF2A3146),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: provider.isSending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 42,
              color: Colors.white.withOpacity(0.28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
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
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(),
          const SizedBox(width: 9),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFF11182A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF202B49)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.senderDisplayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFBFD0FF),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (message.timeText.isNotEmpty)
                        Text(
                          message.timeText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 10.5,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.76),
                      fontSize: 13.5,
                      height: 1.38,
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

  Widget _avatar() {
    if (message.senderAvatarUrl != null &&
        message.senderAvatarUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 17,
        backgroundColor: const Color(0xFF6574FF),
        backgroundImage: NetworkImage(message.senderAvatarUrl!),
      );
    }

    return const CircleAvatar(
      radius: 17,
      backgroundColor: Color(0xFF6574FF),
      child: Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}