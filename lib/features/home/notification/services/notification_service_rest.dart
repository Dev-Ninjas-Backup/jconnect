import 'package:flutter/foundation.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/notification/model/notification_model.dart';

class NotificationServiceRest {
  final NetworkClient networkClient;

  NotificationServiceRest({required this.networkClient});

  Future<Map<String, dynamic>> fetchNotifications() async {
    final response = await networkClient.getRequest(
      url: Endpoint.userNotifications,
    );

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      final List list = response.responseData!['data']['notifications'];
      final int unreadCount = response.responseData!['data']['unreadCount'] ?? 0;
      if (kDebugMode) {
        print("Notification List: $list");
        print("Unread Count: $unreadCount");
      }

      return {
        'notifications': list
            .map((e) => AppNotification.fromJson(e))
            .toList(),
        'unreadCount': unreadCount,
      };
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    final response = await networkClient.patchRequest(
      body: {},
      url: Endpoint.markAllNotificationsRead,
    );

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      if (kDebugMode) {
        print("✅ All notifications marked as read");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("❌ Failed to mark notifications as read");
      }
      return false;
    }
  }
}
