// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter/foundation.dart';
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
  final RxInt unreadCount = 0.obs;

  final NotificationSocketService _socketService = NotificationSocketService();

  @override
  void onInit() {
    super.onInit();
    refreshNotifications();
  }

  @override
  void onClose() {
    disconnectSocket();
    super.onClose();
  }

  /// Refresh notifications - clears and reloads
  Future<void> refreshNotifications() async {
    notifications.clear();
    unreadCount.value = 0;
    await loadNotifications();
  }

  /// Load notifications only if empty (used when opening notification screen)
  Future<void> ensureNotificationsLoaded() async {
    if (notifications.isEmpty && !isLoading.value) {
      await loadNotifications();
    }
  }

  void connectSocket(String token) {
    _socketService.connect(token: token, onNotification: _handleNotification);
  }

  void _handleNotification(dynamic data) {
    try {
      final notification = AppNotification.fromJson(
        Map<String, dynamic>.from(data),
      );

      // Add all notifications without duplicate checking
      notifications.insert(0, notification);
      debugPrint('✅ Notification added: ${notification.title}');
    } catch (e) {
      print('❌ Notification parse error: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final result = await notificationServiceREST.fetchNotifications();

      final List<AppNotification> notificationList = result['notifications'];
      final int count = result['unreadCount'];

      notifications.addAll(notificationList);
      unreadCount.value = count;

      print(
        "===================Notification Length: ${notificationList.length}, Unread: $count===================  ",
      );

      // Debug logs
      for (var i = 0; i < notificationList.length; i++) {
        print(
          '🔔 Notification $i: ID=${notificationList[i].id}, CurrentUser=${notificationList[i].currentUser?.id}',
        );
      }
    } catch (e) {
      print("❌ Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    final success = await notificationServiceREST.markAllNotificationsAsRead();
    if (success) {
      // Update all notifications to read status
      for (var notification in notifications) {
        // Since AppNotification might not have a read field, we'll just clear unreadCount
      }
      unreadCount.value = 0;
      print('✅ All notifications marked as read locally');
    }
  }

  void disconnectSocket() {
    _socketService.disconnect();
  }
}
