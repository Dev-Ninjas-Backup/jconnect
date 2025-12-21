// ignore_for_file: avoid_print

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/notification/model/notification_model.dart';
import 'package:jconnect/features/home/notification/services/notification_service_rest.dart';
import 'package:jconnect/features/home/notification/services/notification_services.dart';

class NotificationController extends GetxController {
  late final NotificationServiceRest notificationServiceREST;

  NotificationController() {
    notificationServiceREST = NotificationServiceRest(
      networkClient: NetworkClient(
        onUnAuthorize: () {
          print("Unauthorized access - Notification");
        },
      ),
    );
  }

  final RxBool isLoading = false.obs;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  final NotificationSocketService _socketService = NotificationSocketService();

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void connectSocket(String token) {
    _socketService.connect(token: token, onNotification: _handleNotification);
  }

  void _handleNotification(dynamic data) {
    try {
      final notification = AppNotification.fromJson(
        Map<String, dynamic>.from(data),
      );

      // 🔥 PREVENT DUPLICATE SOCKET + HTTP
      final exists = notifications.any((n) => n.id == notification.id);

      if (!exists) {
        notifications.insert(0, notification);
      }
    } catch (e) {
      print('❌ Notification parse error: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final notification = await notificationServiceREST.fetchNotifications();

      notifications.addAll(notification);
      print(
        "===================Notification Length: ${notification.length}===================",
      );
    } catch (e) {
      print("❌ Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }
}
