class AppNotification {
  final String type;
  final String title;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic>? meta;

  AppNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.meta,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      type: json['type'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      meta: json['meta'],
    );
  }
}
