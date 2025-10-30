import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import '../model/notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() {
    // Static mock data (replace with API later)
    notifications.value = [
      NotificationModel(
        title: "Payment Successful",
        message: "Your payment for order #12345 was completed successfully.",
        time: "2m ago",
        isRead: false,
        iconPath: Iconpath.paymentIcon,
      ),
      NotificationModel(
        title: "New Message",
        message: "You have a new message from John Doe.",
        time: "1h ago",
        isRead: true,
        iconPath: Iconpath.messageIcon,
      ),

      NotificationModel(
        title: "Weekly Report",
        message: "Your weekly performance report is now available.",
        time: "1d ago",
        isRead: true,
        iconPath: Iconpath.reportIcon,
      ),
    ];
  }

  void markAsRead(int index) {
    notifications[index] = NotificationModel(
      title: notifications[index].title,
      message: notifications[index].message,
      time: notifications[index].time,
      isRead: true,
      iconPath: notifications[index].iconPath,
    );
  }
}
