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
}
