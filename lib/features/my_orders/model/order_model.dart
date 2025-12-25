class OrderModel {
  final String title;
  final String platform;
  final String icon;
  final String type;
  final String status;
  final double price;
  final String? description;
  final String orderId; // database ID for API calls
  final String orderCode; // displayed to user
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
    required this.orderId,
    required this.orderCode,
    this.sellerName = '',
    this.sellerEmail = '',
    this.raw,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      title: json['service']?['serviceName'] ?? '',
      platform: json['service']?['serviceType'] ?? '',
      icon: '', // replace if you have service icon
      type: 'Received',
      status: json['status'] ?? '',
      price: (json['amount'] ?? 0).toDouble(),
      description: json['service']?['description'] ?? '',
      orderId: json['id'] ?? '', // DATABASE ID for API
      orderCode: json['orderCode'] ?? '', // display to user
      raw: json,
      sellerName: json['buyer']?['full_name'] ?? '',
      sellerEmail: json['buyer']?['email'] ?? '',
    );
  }
}
