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

  bool get isConnected => socket?.connected ?? false;

  void connect({
    required String token,
    required Function(dynamic data) onNewMessage,
    Function(String userId)? onSuccess,
  }) {
    // Prevent duplicate listeners / multiple connections.
    if (socket != null) {
      if (socket!.connected) {
        debugPrint('ℹ️ Message socket already connected');
        return;
      }
      socket!.dispose();
      socket = null;
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

    // Listen: private:success - After successful connection
    socket!.on('private:success', (data) {
      debugPrint('✅ Socket connection successful with userId: $data');
      onSuccess?.call(data as String);
    });

    // Listen: private:new_message - When someone sends you a message
    socket!.on('private:new_message', (data) {
      debugPrint('📩 Private new message received: $data');
      onNewMessage(data);
    });

    // Listen: private:conversation_list - After load_conversations or new conversation
    socket!.on('private:conversation_list', (data) {
      debugPrint('✅ List of conversations: $data');
      onNewMessage({'type': 'conversation_list', 'data': data});
    });

    // Listen: private:new_conversation - When a new conversation appears (first message)
    socket!.on('private:new_conversation', (data) {
      debugPrint('✅ New conversation created: $data');
      onNewMessage({'type': 'new_conversation', 'data': data});
    });

    // Listen: private:error - Any error (auth, validation, etc.)
    socket!.on('private:error', (data) {
      debugPrint('❌ Socket error: $data');
    });

    // Manually connect after setting up listeners when auto-connect is disabled
    socket!.connect();
  }

  /// Emit: private:load_conversations - Load all your chats
  void loadAllConversations() {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Socket not connected, cannot load conversations');
      return;
    }

    socket!.emit('private:load_conversations');
    debugPrint('🔄 Emitted: Load all conversations');
  }

  /// Emit: private:load_single_conversation - Load one conversation
  void loadConversation({required String conversationId}) {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Socket not connected, cannot load conversation');
      return;
    }

    socket!.emit('private:load_single_conversation', {
      'conversationId': conversationId,
    });
    debugPrint('🔄 Emitted: Load conversation $conversationId');
  }

  /// Emit: private:send_message - Send message via socket
  /// Payload: SendPrivateMessageDto
  void sendMessage({
    required String recipientId,
    required String content,
    String? serviceId,
    List<String>? files,
  }) {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Socket not connected, cannot send message');
      return;
    }

    final payload = {
      'recipientId': recipientId,
      'content': content,
      if (serviceId != null) 'serviceId': serviceId,
      if (files != null && files.isNotEmpty) 'files': files,
    };

    socket!.emit('private:send_message', payload);
    debugPrint(
      '📤 Emitted: Send message to $recipientId with content: $content',
    );
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    debugPrint('🔌 Socket disconnected and disposed');
  }
}
