class OrderModel {
  final String title;
  final String platform;
  final String icon;
  final String type;
  final String status;
  final double price;
  final String? description;

  OrderModel({
    required this.title,
    required this.platform,
    required this.icon,
    required this.type,
    required this.status,
    required this.price,
    this.description,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      title: json['service']?['serviceName'] ?? '',
      platform: json['service']?['serviceType'] ?? '',
      icon: '',
      type: 'Received',
      status: json['status'] ?? '',
      price: (json['amount'] ?? 0).toDouble(),
      description: json['service']?['description'],
    );
  }
}
