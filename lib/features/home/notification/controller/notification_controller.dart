import 'package:get/get.dart';
import '../model/notification_model.dart';
import '../services/notification_services.dart';

class NotificationController extends GetxController {
  final notifications = <AppNotification>[].obs;

  /// User notification preferences
  final serviceCreationEnabled = true.obs;
  final userRegistrationEnabled = true.obs;

  final NotificationSocketService _socketService =
      NotificationSocketService();

  void connectSocket(String token) {
    _socketService.connect(
      token: token,
      onNotification: _handleNotification,
    );
  }

  void _handleNotification(dynamic data) {
    final notification = AppNotification.fromJson(data);

    switch (notification.type) {
      case 'service.create':
        if (!serviceCreationEnabled.value) return;
        notifications.insert(0, notification);
        print("==================${notifications.length} ===========");
        break;

      case 'user.register':
        if (!userRegistrationEnabled.value) return;
        notifications.insert(0, notification);
        break;

      default:
        // Ignore other notification types
        break;
    }
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }
}



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../model/notification_model.dart';
// import '../services/notification_services.dart';

// class NotificationController extends GetxController {
//   final notifications = <AppNotification>[].obs;
  

//   /// User preferences
//   final serviceCreationEnabled = true.obs;

//   final NotificationSocketService _socketService =
//       NotificationSocketService();

//   void connectSocket(String token) {
//     _socketService.connect(
//       token: token,
//       onEvent: _handleSocketEvent,
//     );
//   }

//   void _handleSocketEvent(String event, dynamic data) {
//     if (event != 'notification') return;

//     final notification = AppNotification.fromJson(data);

//     switch (notification.type) {
//       case 'service.create':
//         if (!serviceCreationEnabled.value) return;
//         notifications.insert(0, notification);
//         debugPrint('Service length : ${notifications.length}');
//         break;

//       default:
//         // ignore other notification types
//         break;
//     }
//   }

//   void disconnectSocket() {
//     _socketService.disconnect();
//   }
// }
