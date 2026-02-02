class FollowModel {
  final String id;
  final String email;
  final String fullName;

  FollowModel({required this.id, required this.email, required this.fullName});

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
    );
  }

  @override
  String toString() => 'FollowModel(id: $id, name: $fullName, email: $email)';
}
