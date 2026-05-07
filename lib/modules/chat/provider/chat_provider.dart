import 'package:flutter/material.dart';

import '../model/chat_room.dart';
import '../model/message.dart';
import '../service/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required this.chatService,
  });

  final ChatService chatService;

  bool isLoadingRooms = false;
  bool isLoadingMessages = false;
  bool isSending = false;
  String? errorMessage;

  List<ChatRoom> rooms = [];
  List<Message> messages = [];
  ChatRoom? selectedRoom;

  Future<void> loadRooms() async {
    try {
      isLoadingRooms = true;
      errorMessage = null;
      notifyListeners();

      rooms = await chatService.getRooms();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingRooms = false;
      notifyListeners();
    }
  }

  Future<void> openRoom(ChatRoom room) async {
    try {
      selectedRoom = room;
      isLoadingMessages = true;
      errorMessage = null;
      messages = [];
      notifyListeners();

      messages = await chatService.getMessages(room.id);
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> refreshMessages() async {
    if (selectedRoom == null) return;

    try {
      isLoadingMessages = true;
      errorMessage = null;
      notifyListeners();

      messages = await chatService.getMessages(selectedRoom!.id);
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String content) async {
    if (selectedRoom == null) {
      errorMessage = 'Chưa chọn phòng chat';
      notifyListeners();
      return false;
    }

    final cleanContent = content.trim();

    if (cleanContent.isEmpty) {
      errorMessage = 'Vui lòng nhập tin nhắn';
      notifyListeners();
      return false;
    }

    if (cleanContent.length > 1000) {
      errorMessage = 'Tin nhắn không được vượt quá 1000 ký tự';
      notifyListeners();
      return false;
    }

    try {
      isSending = true;
      errorMessage = null;
      notifyListeners();

      await chatService.sendMessage(
        roomId: selectedRoom!.id,
        content: cleanContent,
      );

      messages = await chatService.getMessages(selectedRoom!.id);

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  void clearRoom() {
    selectedRoom = null;
    messages = [];
    errorMessage = null;
    notifyListeners();
  }
}