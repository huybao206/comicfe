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
    if (selectedRoom == null) return false;
    if (content.trim().isEmpty) return false;

    try {
      isSending = true;
      errorMessage = null;
      notifyListeners();

      final sent = await chatService.sendMessage(
        roomId: selectedRoom!.id,
        content: content.trim(),
      );

      if (sent != null) {
        messages = [...messages, sent];
      } else {
        await refreshMessages();
      }

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
    notifyListeners();
  }
}