// ignore: library_prefixes
import 'dart:async';
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
  String? _token;
  Function(dynamic data)? _onNotification;
  Timer? _reconnectTimer;
  Timer? _healthCheckTimer;
  bool _isConnecting = false;
  static const int _reconnectDelay = 5; // seconds
  static const int _healthCheckInterval = 30; // seconds

  void connect({
    required String token,
    required Function(dynamic data) onNotification,
  }) {
    // Don't reconnect if already connecting or connected
    if (_isConnecting || (socket?.connected ?? false)) {
      debugPrint('❌ Socket already connecting or connected');
      return;
    }

    _token = token;
    _onNotification = onNotification;
    _isConnecting = true;

    _createSocketConnection();
  }

  void _createSocketConnection() {
    if (socket != null) {
      socket!.dispose();
      socket = null;
    }

    socket = IO.io(
      Endpoint.notificationsIO,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': _token})
          .setExtraHeaders({'Authorization': "Bearer $_token"})
          // Add reconnection configuration
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .enableForceNew()
          .build(),
    );

    _attachSocketListeners();
  }

  void _attachSocketListeners() {
    if (socket == null) return;

    socket!.onConnect((_) {
      debugPrint('✅ Notification socket connected');
      _isConnecting = false;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _startHealthCheck();
    });

    socket!.onDisconnect((_) {
      debugPrint('❌ Notification socket disconnected');
      _isConnecting = false;
      _stopHealthCheck();
      _scheduleReconnect();
    });

    socket!.onConnectError((err) {
      debugPrint('⚠️ Socket connect error: $err');
      _isConnecting = false;
      _stopHealthCheck();
      _scheduleReconnect();
    });

    socket!.on('error', (data) {
      debugPrint('❌ Socket error event: $data');
      _scheduleReconnect();
    });

    socket!.on('connect_error', (error) {
      debugPrint('❌ Socket connection error: $error');
      _stopHealthCheck();
      _scheduleReconnect();
    });

    /// Backend emits notifications
    socket!.on('service.create', (data) {
      debugPrint('✅ Service created notification received: $data');
      _onNotification?.call(data);
    });

    socket!.on('inquiry.create', (data) {
      debugPrint('✅ Inquiry created notification received: $data');
      _onNotification?.call(data);
    });

    socket!.connect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelay), () {
      if (!_isConnecting && (_token != null)) {
        debugPrint('🔄 Attempting to reconnect notification socket...');
        _isConnecting = true;
        _createSocketConnection();
      }
    });
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      Duration(seconds: _healthCheckInterval),
      (_) {
        if (socket?.connected ?? false) {
          debugPrint('💓 Socket health check - Connected');
        } else {
          debugPrint(
            '⚠️ Socket health check - Disconnected, attempting to reconnect',
          );
          _scheduleReconnect();
        }
      },
    );
  }

  void _stopHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _token = null;
    _onNotification = null;
    _isConnecting = false;
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    debugPrint('🔌 Notification socket disconnected and cleaned up');
  }

  Future<List<dynamic>> fetchNotifications(String token) async {
    final response = await http.get(
      Uri.parse(Endpoint.userNotifications),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return body['data']['notifications'];
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
