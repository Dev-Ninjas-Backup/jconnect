// class OrderModel {
//   final String title;
//   final String platform;
//   final String icon;
//   final String type;
//   final String status;
//   final double price;
//   final String? description;
//   final String orderId; // database ID for API calls
//   final String orderCode; // displayed to user
//   final Map<String, dynamic>? raw;
//   final String sellerName;
//   final String sellerEmail;

//   OrderModel({
//     required this.title,
//     required this.platform,
//     required this.icon,
//     required this.type,
//     required this.status,
//     required this.price,
//     this.description,
//     required this.orderId,
//     required this.orderCode,
//     this.sellerName = '',
//     this.sellerEmail = '',
//     this.raw,
//   });

//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       title: json['service']?['serviceName'] ?? '',
//       platform: json['service']?['serviceType'] ?? '',
//       icon: '', // replace if you have service icon
//       type: 'Received',
//       status: json['status'] ?? '',
//       price: (json['amount'] ?? 0).toDouble(),
//       description: json['service']?['description'] ?? '',
//       orderId: json['id'] ?? '', // DATABASE ID for API
//       orderCode: json['orderCode'] ?? '', // display to user
//       raw: json,
//       sellerName: json['buyer']?['full_name'] ?? '',
//       sellerEmail: json['buyer']?['email'] ?? '',
//     );
//   }

//   factory OrderModel.fromPaidOrderJson(Map<String, dynamic> json) {
//     return OrderModel(
//       title: json['service']?['serviceName'] ?? '',
//       platform: json['service']?['serviceType'] ?? '',
//       icon: '', // replace if you have service icon
//       type: 'Purchased',
//       status: json['status'] ?? '',
//       price:
//           (json['amount'] ?? 0).toDouble() /
//           100, // Convert from cents to dollars
//       description: json['service']?['description'] ?? '',
//       orderId: json['id'] ?? '', // DATABASE ID for API
//       orderCode: json['orderCode'] ?? '', // display to user
//       raw: json,
//       sellerName: json['seller']?['full_name'] ?? '',
//       sellerEmail: json['seller']?['email'] ?? '',
//     );
//   }
// }

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
    );
  }
}
