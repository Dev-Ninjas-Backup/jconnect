class DisputeModel {
  final String userName;
  final String dealTitle;
  final String description;
  final String date;
  final double amount;
  final String status;

  DisputeModel({
    required this.userName,
    required this.dealTitle,
    required this.description,
    required this.date,
    required this.amount,
    required this.status,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    String extractUserName() {
      // 1. Check order seller username / user_name
      final orderSeller = json['order']?['seller'];
      if (orderSeller is Map) {
        final u = orderSeller['username'] ?? orderSeller['user_name'];
        if (u != null && u.toString().trim().isNotEmpty) {
          return u.toString().trim();
        }
      }

      // 2. Check user username / user_name
      final user = json['user'];
      if (user is Map) {
        final u = user['username'] ?? user['user_name'];
        if (u != null && u.toString().trim().isNotEmpty) {
          return u.toString().trim();
        }
      }

      // 3. Check direct username / user_name field
      final directUser =
          json['username'] ?? json['user_name'] ?? json['userName'];
      if (directUser != null && directUser.toString().trim().isNotEmpty) {
        return directUser.toString().trim();
      }

      // 4. Fallback to full_name if username is not present
      return json['order']?['seller']?['full_name'] ??
          json['user']?['full_name'] ??
          json['full_name'] ??
          'Unknown';
    }

    return DisputeModel(
      userName: extractUserName(),
      dealTitle: json['order']?['service']?['serviceName'] ??
          json['order']?['serviceTitle'] ??
          json['serviceTitle'] ??
          'Unknown',
      description: json['description']?.toString() ?? '',
      date: (json['createdAt'] ?? json['date'] ?? '').toString(),
      amount: (json['order']?['amount'] ?? json['amount'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'PENDING',
    );
  }
}
