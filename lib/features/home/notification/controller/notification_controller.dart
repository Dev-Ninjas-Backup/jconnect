// // ignore_for_file: avoid_print

// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:jconnect/features/home/notification/model/notification_model.dart';
// import 'package:jconnect/features/home/notification/services/notification_services.dart';

// class NotificationController extends GetxController {
//   final RxList<AppNotification> notifications = <AppNotification>[].obs;

//   final NotificationSocketService _socketService = NotificationSocketService();

//   void connectSocket(String token) {
//     _socketService.connect(token: token, onNotification: _handleNotification);
//   }

//   void _handleNotification(dynamic data) {
//     try {
//       final notification = AppNotification.fromJson(
//         Map<String, dynamic>.from(data),
//       );

//       notifications.insert(0, notification);

//       print("Notifiaaton Length: ${notifications.length}");
//     } catch (e) {
//       print('❌ Notification parse error: $e');
//     }
//   }

//   void disconnectSocket() {
//     _socketService.disconnect();
//   }
// }


// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import '../model/notification_model.dart';
import '../services/notification_services.dart';

class NotificationController extends GetxController {
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
    final prefs = Get.put(SharedPreferencesHelperController());

  final NotificationSocketService _socketService =
      NotificationSocketService();
  final NotificationSocketService _apiService =
      NotificationSocketService();

  /// Used to prevent duplicates
  final Set<String> _notificationIds = {};

  /// 1️⃣ Load old notifications via HTTP
  Future<void> fetchNotifications() async {
    final token1 = await prefs.getAccessRowToken()??"";
  
    try {
      final data = await _apiService.fetchNotifications(token1);

      final fetched = data
          .map((e) => AppNotification.fromJson(e))
          .toList();

      for (final notification in fetched) {
        if (!_notificationIds.contains(notification.id)) {
          _notificationIds.add(notification.id??" ");
          notifications.add(notification);
        }
      }

      /// newest first
      notifications.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
    } catch (e) {
      print('❌ HTTP fetch error: $e');
    }
  }

  /// 2️⃣ Listen realtime socket notifications
  void connectSocket(String token) {
    _socketService.connect(
      token: token,
      onNotification: _handleSocketNotification,
    );
  }

  void _handleSocketNotification(dynamic data) {
    try {
      final notification = AppNotification.fromJson(
        Map<String, dynamic>.from(data),
      );

      if (_notificationIds.contains(notification.id)) return;

      _notificationIds.add(notification.id??"");
      notifications.insert(0, notification);

      print('🔔 Total notifications: ${notifications.length}');
    } catch (e) {
      print('❌ Socket parse error: $e');
    }
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }
}
