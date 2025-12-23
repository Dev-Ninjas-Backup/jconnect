import 'package:flutter/foundation.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/notification/model/notification_model.dart';

class NotificationServiceRest {
  final NetworkClient networkClient;

  NotificationServiceRest({required this.networkClient});

  Future<List<AppNotification>> fetchNotifications() async {
    final response = await networkClient.getRequest(
      url: Endpoint.userNotifications,
    );

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      final List list = response.responseData!['data']['notifications'];
      if (kDebugMode) {
        print("Notification List: $list");
      }

      return list
          .map((e) => AppNotification.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
