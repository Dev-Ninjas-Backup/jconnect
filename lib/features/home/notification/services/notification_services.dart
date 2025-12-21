// ignore: library_prefixes
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class NotificationSocketService {
  static final NotificationSocketService _instance =
      NotificationSocketService._internal();

  factory NotificationSocketService() => _instance;
  NotificationSocketService._internal();

  IO.Socket? socket;

  void connect({
    required String token,
    required Function(dynamic data) onNotification,
  }) {
    socket = IO.io(
      Endpoint.notificationsIO,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': "Bearer $token"})
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('✅ Notification socket connected');
    });

    socket!.onDisconnect((_) {
      debugPrint('❌ Notification socket disconnected');
    });

    socket!.onConnectError((err) {
      debugPrint('⚠️ Socket connect error: $err');
    });

    /// Backend emits ALL notifications on one event
    //socket!.on('notification', onNotification);
    socket!.on('service.create', (data) {
      debugPrint('Service created notification received: $data');
      onNotification(data);
    });

    socket!.connect();
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }



  Future<List<dynamic>> fetchNotifications(String token) async {
    final response = await http.get(
      Uri.parse(Endpoint.userNotifications),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200||response.statusCode==201) {
      final body = jsonDecode(response.body);
      return body['data']['notifications'];
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
