class OrderModel {
  final String platform;
  final String title;
  final String status;
  final double price;
  final String icon;
  final String type; // ✅ New field: "Given" or "Received"

  OrderModel({
    required this.platform,
    required this.title,
    required this.status,
    required this.price,
    required this.icon,
    required this.type,
  });
}