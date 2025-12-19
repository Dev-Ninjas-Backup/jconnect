class OrderModel {
  final String title;
  final String platform;
  final String icon;
  final String type;
  final String status;
  final double price;
  final String? description;
  final String? orderId;
  final Map<String, dynamic>? raw;
  final String sellerName;
  final String sellerEmail;

  OrderModel({
    required this.title,
    required this.platform,
    required this.icon,
    required this.type,
    required this.status,
    required this.price,
    this.description,
    this.orderId,
    this.sellerName = '',
    this.sellerEmail = '',
    this.raw,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      title: json['service']?['serviceName'] ?? '',
      platform: json['service']?['serviceType'] ?? '',
      icon: '',
      type: 'Received',
      status: json['status'] ?? '',
      price: (json['amount'] ?? 0).toDouble(),
      orderId: json['orderCode'] ?? '',
      raw: json,
      sellerName: json['seller']?['full_name'] ?? json['seller']?['name'] ?? '',
      sellerEmail: json['seller']?['email'] ?? '',
      //description: json['service']?['description'] ?? '',
    );
  }
}
