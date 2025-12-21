import 'package:flutter/material.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessageSocketService {
  static final MessageSocketService _instance =
      MessageSocketService._internal();

  factory MessageSocketService() => _instance;
  MessageSocketService._internal();

  IO.Socket? socket;

  void connect({
    required String token,
    required Function(dynamic data) onNewMessage,
  }) {
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

    ///  Incoming private message
    socket!.on('private:new_message', (data) {
      debugPrint('📩 Private new message received: $data');
      onNewMessage(data);
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
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
