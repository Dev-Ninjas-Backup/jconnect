// ignore_for_file: avoid_print

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jconnect/features/home/notification/model/notification_model.dart';
import 'package:jconnect/features/home/notification/services/notification_services.dart';

class NotificationController extends GetxController {
  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  final NotificationSocketService _socketService = NotificationSocketService();

  void connectSocket(String token) {
    _socketService.connect(token: token, onNotification: _handleNotification);
  }

  void _handleNotification(dynamic data) {
    try {
      final notification = AppNotification.fromJson(
        Map<String, dynamic>.from(data),
      );

      notifications.insert(0, notification);

      print("Notifiaaton Length: ${notifications.length}");
    } catch (e) {
      print('❌ Notification parse error: $e');
    }
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }
}
