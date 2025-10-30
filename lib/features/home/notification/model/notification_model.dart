class NotificationModel {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String iconPath;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.iconPath,
  });
}
