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
    return DisputeModel(
      userName: json['order']['seller']['full_name'] ?? 'Unknown',
      dealTitle: json['order']['service']['serviceName'] ?? 'Unknown',
      description: json['description'] ?? '',
      date: json['createdAt'] ?? '',
      amount: (json['order']['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
    );
  }
}
