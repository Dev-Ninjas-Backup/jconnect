import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jconnect/core/endpoint.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Represents an event received from the order socket.
class OrderSocketEvent {
  final String event;
  final dynamic data;

  OrderSocketEvent(this.event, this.data);

  @override
  String toString() => 'OrderSocketEvent(event: $event, data: $data)';
}

class OrderSocketService {
  static final OrderSocketService _instance = OrderSocketService._internal();

  factory OrderSocketService() => _instance;
  OrderSocketService._internal();

  IO.Socket? socket;
  final _eventController = StreamController<OrderSocketEvent>.broadcast();

  /// Stream of all events emitted by the socket server.
  Stream<OrderSocketEvent> get eventStream => _eventController.stream;

  /// Check if the socket is currently connected.
  bool get isConnected => socket?.connected == true;

  /// Establishes socket connection with namespace wss://[host]/order.
  void connect({required String token}) {
    if (socket != null) {
      if (socket!.connected) {
        debugPrint('ℹ️ Order socket already connected');
        return;
      }
      disconnect();
    }

    final rawToken = token.startsWith('Bearer ') ? token.substring(7) : token;
    final formattedToken = 'Bearer $rawToken';

    debugPrint('🔄 Connecting to Order socket namespace: ${Endpoint.orderSocketIO}');
    debugPrint('🔑 Auth Token: $formattedToken');

    socket = IO.io(
      Endpoint.orderSocketIO,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': formattedToken})
          .setExtraHeaders({'Authorization': formattedToken})
          .disableAutoConnect()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .enableForceNew()
          .build(),
    );

    // Standard Socket.IO system events
    socket!.onConnect((_) {
      debugPrint('✅ Order socket connected');
    });

    socket!.onDisconnect((_) {
      debugPrint('❌ Order socket disconnected');
    });

    socket!.onConnectError((err) {
      debugPrint('⚠️ Order socket connect error: $err');
      _eventController.add(OrderSocketEvent('order:error', {'message': err.toString()}));
    });

    // Server -> Client events
    socket!.on('order:error', (data) {
      debugPrint('❌ Order socket error event: $data');
      _eventController.add(OrderSocketEvent('order:error', data));
    });

    socket!.on('order:success', (data) {
      debugPrint('✅ Order socket success acknowledgment: $data');
      _eventController.add(OrderSocketEvent('order:success', data));
    });

    socket!.on('order:created', (data) {
      debugPrint('📩 Order created: $data');
      _eventController.add(OrderSocketEvent('order:created', data));
    });

    socket!.on('order:in_progress', (data) {
      debugPrint('📩 Order in progress: $data');
      _eventController.add(OrderSocketEvent('order:in_progress', data));
    });

    socket!.on('order:proof_submitted', (data) {
      debugPrint('📩 Order proof submitted: $data');
      _eventController.add(OrderSocketEvent('order:proof_submitted', data));
    });

    socket!.on('order:released', (data) {
      debugPrint('📩 Order released: $data');
      _eventController.add(OrderSocketEvent('order:released', data));
    });

    socket!.on('order:cancelled', (data) {
      debugPrint('📩 Order cancelled: $data');
      _eventController.add(OrderSocketEvent('order:cancelled', data));
    });

    socket!.on('order:delivery_date_updated', (data) {
      debugPrint('📩 Order delivery date updated: $data');
      _eventController.add(OrderSocketEvent('order:delivery_date_updated', data));
    });

    socket!.on('order:proof_cancelled', (data) {
      debugPrint('📩 Order proof cancelled: $data');
      _eventController.add(OrderSocketEvent('order:proof_cancelled', data));
    });

    socket!.on('order:deleted', (data) {
      debugPrint('📩 Order deleted: $data');
      _eventController.add(OrderSocketEvent('order:deleted', data));
    });

    socket!.on('order:get_order', (data) {
      debugPrint('📩 Order get_order response: $data');
      _eventController.add(OrderSocketEvent('order:get_order', data));
    });

    // Manually connect
    socket!.connect();
  }

  /// Verifies participant status and joins room `order:<orderId>`.
  void joinOrder(String orderId) {
    if (socket == null) {
      debugPrint('⚠️ Cannot join order room. Socket is null.');
      return;
    }
    if (socket!.connected) {
      socket!.emit('order:join_order', orderId);
      debugPrint('📤 Emitted joinOrder room for orderId: $orderId');
    } else {
      debugPrint('⏳ Socket not connected yet. Queueing joinOrder room for orderId: $orderId on next connect.');
      socket!.once('connect', (_) {
        if (socket?.connected == true) {
          socket!.emit('order:join_order', orderId);
          debugPrint('📤 Emitted joinOrder room for orderId: $orderId (on connect callback)');
        }
      });
    }
  }

  /// Leaves room `order:<orderId>`.
  void leaveOrder(String orderId) {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Cannot leave order room. Socket not connected.');
      return;
    }
    socket!.emit('order:leave_order', orderId);
    debugPrint('📤 Emitted leaveOrder room for orderId: $orderId');
  }

  /// Requests a one-shot fetch of order state. Response comes on `order:get_order`.
  void getOrder(String orderId) {
    if (socket == null || !socket!.connected) {
      debugPrint('⚠️ Cannot get order. Socket not connected.');
      return;
    }
    socket!.emit('order:get_order', orderId);
    debugPrint('📤 Emitted getOrder request for orderId: $orderId');
  }

  /// Disconnects the socket connection and cleans up.
  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      debugPrint('🔌 Order socket disconnected and resources disposed');
    }
  }
}
