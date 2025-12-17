
// // ignore: library_prefixes
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:flutter/foundation.dart';

// class NotificationSocketService {
//   static final NotificationSocketService _instance =
//       NotificationSocketService._internal();

//   factory NotificationSocketService() => _instance;
//   NotificationSocketService._internal();

//   IO.Socket? socket;

//   void connect({
//     required String token,
//     required Function(String event, dynamic data) onEvent,
//   }) {
//     socket = IO.io(
//       'https://jconnect-server.saikat.com.bd/notification',
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .disableAutoConnect()
//           .setAuth({'token': token}) 
//           .setExtraHeaders({
//             'Authorization': token,
//           })
//           .build(),
//     );

//     socket!.onConnect((_) {
//       debugPrint('✅ Notification socket connected');
//     });

//     socket!.onDisconnect((reason) {
//       debugPrint('❌ Notification socket disconnected: $reason');
//     });

//     socket!.onConnectError((err) {
//       debugPrint('⚠️ Socket connect error: $err');
//     });

//     /// Listen to ALL events (important)
//     socket!.onAny((event, data) {
//       onEvent(event, data);
//     });

//     socket!.connect();
//   }

//   void disconnect() {
//     socket?.disconnect();
//     socket?.dispose();
//     socket = null;
//   }
// }


// ignore: library_prefixes
import 'package:flutter/foundation.dart';
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
      'https://jconnect-server.saikat.com.bd/notification',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token}) // RAW TOKEN
          .setExtraHeaders({
            'Authorization': token,
          })
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
    socket!.on('notification', onNotification);

    socket!.connect();
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
