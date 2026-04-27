import 'package:flutter/material.dart';
import 'package:jconnect/core/endpoint.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessageSocketService {
  static final MessageSocketService _instance =
      MessageSocketService._internal();

  factory MessageSocketService() => _instance;
  MessageSocketService._internal();

  IO.Socket? socket;

  bool get isConnected => socket?.connected == true;

  void connect({
    required String token,
    required Function(dynamic data) onNewMessage,
  }) {
    // Avoid attaching duplicate listeners / multiple sockets (common during hot-reload
    // or when screens call initialize multiple times).
    if (socket != null) {
      if (socket!.connected) {
        debugPrint('ℹ️ Message socket already connected');
        return;
      }
      disconnect();
    }

    socket = IO.io(
      Endpoint.chatSocketIO,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .disableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('✅ Message socket connected');
    });

    socket!.onDisconnect((_) {
      debugPrint('❌ Message socket disconnected');
    });

    socket!.onConnectError((err) {
      debugPrint('⚠️ Socket connect error: $err');
    });

       socket!.on('serviceRequestUpdated', (data) {
      debugPrint('📩 Service request updated: $data');
      onNewMessage(data);
    });


       socket!.on('serviceRequestFilesUpdated', (data) {
      debugPrint('📩 Service request files updated: $data');
      onNewMessage(data);
    });

    ///  Incoming private message
    socket!.on('private:new_message', (data) {
      debugPrint('📩 Private new message received: $data');
      onNewMessage(data);
    });

    socket!.on('private:conversation_list', (data) {
      debugPrint('✅ List of conversations: $data');
      onNewMessage(data);
      // Handle read receipt if needed
    });

    socket!.on('private:new_conversation', (data) {
      debugPrint('✅Update conversation list: $data');
      onNewMessage(data);
      // Handle read receipt if needed
    });

    /// Listen for single conversation data (when loading a specific conversation)
    socket!.on('private:single_conversation', (data) {
      debugPrint('📖 Single conversation loaded: $data');
      onNewMessage(data);
    });

    socket!.on('private:success', (data) {
      debugPrint('✅ Socket connection successful: $data');
    });

    socket!.on('private:error', (data) {
      debugPrint('❌ Socket error: $data');
    });

    // Manually connect after setting up listeners when auto-connect is disabled
    socket!.connect();
  }

  ///  Send message ONLY when user sends
  void sendMessage({
    required String recipientId,
    required String content,
    String? serviceId,
    List<String>? files,
  }) {
    if (socket == null || !socket!.connected) return;

    socket!.emit('private:send_message', {
      'recipientId': recipientId,
      'content': content,
      'serviceId': serviceId,
      'files': files ?? [],
    });
    debugPrint('📤 Message sent: to $recipientId, content: $content');
  }

  void loadConversation({required String conversationId}) {
    if (socket == null || !socket!.connected) return;

    socket!.emit('private:load_single_conversation', {
      'conversationId': conversationId,
    });
    debugPrint('🔄 Load conversation: $conversationId');
  }

  void loadAllChatConversation() {
    if (socket == null || !socket!.connected) return;

    socket!.emit('private:load_conversations', {});
    debugPrint('🔄 Load all conversations');
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
