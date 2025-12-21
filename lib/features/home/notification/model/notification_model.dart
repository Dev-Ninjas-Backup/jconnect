class AppNotification {
  final String? id;
  final String? type;
  final String title;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic>? meta;

  AppNotification({
    this.id,
    this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.meta,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String?,
      type: json['type'] as String?,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      meta: json['metadata'],
    );
  }
}
