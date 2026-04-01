// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
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

  /// Force refresh notifications (e.g., when coming from FCM notification tap)
  /// This always reloads, regardless of current state
  Future<void> forceRefreshNotifications() async {
    if (!isLoading.value) {
      notifications.clear();
      await loadNotifications();
    }
  }

  void connectSocket(String token) {
    // Disconnect any existing socket before connecting new one
   // disconnectSocket();
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

      // Connect socket for real-time notifications if not already connected
      _connectSocketIfNeeded();
    } catch (e) {
      print("❌ Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Connect socket for real-time notifications
  Future<void> _connectSocketIfNeeded() async {
    try {
      // Get access token from SharedPreferencesHelperController
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessToken();
      if (token != null && token.isNotEmpty) {
        connectSocket(token);
      }
    } catch (e) {
      print('⚠️ Could not connect socket: $e');
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
