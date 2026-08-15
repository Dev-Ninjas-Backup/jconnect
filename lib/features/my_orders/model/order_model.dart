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
  final String sellerUsername;
  final String sellerImageUrl;
  final String createdAt;
  final String updatedAt;

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
    this.sellerUsername = '',
    this.sellerImageUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.raw,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      title: json['service']?['serviceName'] ?? '',
      platform: json['service']?['serviceType'] ?? '',
      icon: '', // replace if you have service icon
      type: 'Received',
      status: json['status'] ?? '',
      price: (json['service']?['price'] ?? 0).toDouble(),
      description: json['service']?['description'] ?? '',
      orderId: json['id'] ?? '', // DATABASE ID for API
      orderCode: json['orderCode'] ?? '', // display to user
      raw: json,
      sellerName: json['buyer']?['full_name'] ?? '',
      sellerEmail: json['buyer']?['email'] ?? '',
      sellerUsername: json['buyer']?['username'] ?? '',
      sellerImageUrl: json['buyer']?['profilePhoto'] ?? json['buyer']?['imageUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? json['createdAt'] ?? '',
    );
  }

  factory OrderModel.fromPaidOrderJson(Map<String, dynamic> json) {
    return OrderModel(
      title: json['service']?['serviceName'] ?? '',
      platform: json['service']?['serviceType'] ?? '',
      icon: '', // replace if you have service icon
      type: 'Purchased',
      status: json['status'] ?? '',
      price:
          (json['amount'] ?? 0).toDouble() /
          100, // Convert from cents to dollars
      description: json['service']?['description'] ?? '',
      orderId: json['id'] ?? '', // DATABASE ID for API
      orderCode: json['orderCode'] ?? '', // display to user
      raw: json,
      sellerName: json['seller']?['full_name'] ?? '',
      sellerEmail: json['seller']?['email'] ?? '',
      sellerUsername: json['seller']?['username'] ?? '',
      sellerImageUrl: json['seller']?['profilePhoto'] ?? json['seller']?['imageUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? json['createdAt'] ?? '',
    );
  }

  /// ✅ Add this method for easy updates
  OrderModel copyWith({
    String? title,
    String? platform,
    String? icon,
    String? type,
    String? status,
    double? price,
    String? description,
    String? orderId,
    String? orderCode,
    Map<String, dynamic>? raw,
    String? sellerName,
    String? sellerEmail,
    String? sellerUsername,
    String? sellerImageUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return OrderModel(
      title: title ?? this.title,
      platform: platform ?? this.platform,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      status: status ?? this.status,
      price: price ?? this.price,
      description: description ?? this.description,
      orderId: orderId ?? this.orderId,
      orderCode: orderCode ?? this.orderCode,
      raw: raw ?? this.raw,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      sellerImageUrl: sellerImageUrl ?? this.sellerImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a suitable status message based on status and order type
  String get statusMessage {
    final s = status.toUpperCase().trim();
    final isReceived = type == 'Received';

    if (s.contains('CANCEL') || s.contains('REJECT')) {
      return 'Order cancelled';
    } else if (s.contains('COMPLET') || s.contains('RELEASE')) {
      return isReceived
          ? 'Order completed & funds released'
          : 'Order completed';
    } else if (s.contains('PROOF') || s.contains('SUBMIT')) {
      return isReceived
          ? 'Proof submitted, awaiting review'
          : 'Proof submitted, review required';
    } else if (s.contains('ACCEPT') || s.contains('PROGRESS') || s.contains('WORK')) {
      return isReceived
          ? 'Order in progress'
          : 'Creator is working on order';
    } else if (s.contains('PENDING') || s.contains('PAYMENT')) {
      return isReceived
          ? 'Order received, action required'
          : 'Order placed, payment processed';
    } else if (s.contains('REVISION')) {
      return isReceived
          ? 'Revision requested by buyer'
          : 'Revision request sent to creator';
    }

    if (s.isNotEmpty) {
      final formatted = s[0].toUpperCase() + s.substring(1).toLowerCase();
      return 'Order $formatted';
    }
    return isReceived ? 'Order received' : 'You paid';
  }
}
