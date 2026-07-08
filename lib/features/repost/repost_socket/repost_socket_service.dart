import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jconnect/core/endpoint.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Represents an event received from the repost socket.
class RepostSocketEvent {
  final String event;
  final dynamic data;

  RepostSocketEvent(this.event, this.data);

  @override
  String toString() => 'RepostSocketEvent(event: $event, data: $data)';
}

class RepostSocketService {
  static final RepostSocketService _instance = RepostSocketService._internal();

  factory RepostSocketService() => _instance;
  RepostSocketService._internal();

  IO.Socket? socket;
  final _eventController = StreamController<RepostSocketEvent>.broadcast();

  /// Stream of all events emitted by the socket server.
  Stream<RepostSocketEvent> get eventStream => _eventController.stream;

  /// Check if the socket is currently connected.
  bool get isConnected => socket?.connected == true;

  /// Establishes socket connection with namespace wss://[host]/repost.
  void connect({required String token}) {
    if (socket != null) {
      if (socket!.connected) {
        debugPrint('ℹ️ Repost socket already connected');
        return;
      }
      disconnect();
    }

    debugPrint('🔄 Connecting to Repost socket namespace: ${Endpoint.repostSocketIO}');

    socket = IO.io(
      Endpoint.repostSocketIO,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer $token'})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .disableAutoConnect()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .enableForceNew()
          .build(),
    );

    // Standard Socket.IO system events
    socket!.onConnect((_) {
      debugPrint('✅ Repost socket connected');
    });

    socket!.onDisconnect((_) {
      debugPrint('❌ Repost socket disconnected');
    });

    socket!.onConnectError((err) {
      debugPrint('⚠️ Repost socket connect error: $err');
      _eventController.add(RepostSocketEvent('repost:error', {'message': err.toString()}));
    });

    // Server -> Client events
    socket!.on('repost:error', (data) {
      debugPrint('❌ Repost socket error event: $data');
      _eventController.add(RepostSocketEvent('repost:error', data));
    });

    socket!.on('repost:success', (data) {
      debugPrint('✅ Repost socket success acknowledgment: $data');
      _eventController.add(RepostSocketEvent('repost:success', data));
    });

    socket!.on('repost:order_created', (data) {
      debugPrint('📩 Repost order created: $data');
      _eventController.add(RepostSocketEvent('repost:order_created', data));
    });

    socket!.on('repost:seller_accepted', (data) {
      debugPrint('📩 Repost seller accepted: $data');
      _eventController.add(RepostSocketEvent('repost:seller_accepted', data));
    });

    socket!.on('repost:seller_rejected', (data) {
      debugPrint('📩 Repost seller rejected: $data');
      _eventController.add(RepostSocketEvent('repost:seller_rejected', data));
    });

    socket!.on('repost:proof_submitted', (data) {
      debugPrint('📩 Repost proof submitted: $data');
      _eventController.add(RepostSocketEvent('repost:proof_submitted', data));
    });

    socket!.on('repost:redo_requested', (data) {
      debugPrint('📩 Repost redo requested: $data');
      _eventController.add(RepostSocketEvent('repost:redo_requested', data));
    });

    socket!.on('repost:order_completed', (data) {
      debugPrint('📩 Repost order completed: $data');
      _eventController.add(RepostSocketEvent('repost:order_completed', data));
    });

    socket!.on('repost:order_refunded', (data) {
      debugPrint('📩 Repost order refunded: $data');
      _eventController.add(RepostSocketEvent('repost:order_refunded', data));
    });

    socket!.on('repost:countdown_alert', (data) {
      debugPrint('📩 Repost countdown alert: $data');
      _eventController.add(RepostSocketEvent('repost:countdown_alert', data));
    });

    socket!.on('repost:get_order', (data) {
      debugPrint('📩 Repost get_order response: $data');
      _eventController.add(RepostSocketEvent('repost:get_order', data));
    });

    // Manually connect
    socket!.connect();
  }

  /// Verifies participant status and joins room `order:<orderId>`.
  void joinOrder(String orderId) {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Cannot join order room. Socket not connected.');
      return;
    }
    socket!.emit('repost:join_order', orderId);
    debugPrint('📤 Emitted joinOrder room for orderId: $orderId');
  }

  /// Leaves room `order:<orderId>`.
  void leaveOrder(String orderId) {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Cannot leave order room. Socket not connected.');
      return;
    }
    socket!.emit('repost:leave_order', orderId);
    debugPrint('📤 Emitted leaveOrder room for orderId: $orderId');
  }

  /// Requests a one-shot fetch of order state. Response comes on `repost:get_order`.
  void getOrder(String orderId) {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Cannot get order. Socket not connected.');
      return;
    }
    socket!.emit('repost:get_order', orderId);
    debugPrint('📤 Emitted getOrder request for orderId: $orderId');
  }

  /// Disconnects the socket connection and cleans up.
  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      debugPrint('🔌 Repost socket disconnected and resources disposed');
    }
  }
}
