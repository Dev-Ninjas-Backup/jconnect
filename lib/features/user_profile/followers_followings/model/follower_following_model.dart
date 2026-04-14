class FollowModel {
  final String id;
  final String username;
  final String? profilePhoto;

  FollowModel({
    required this.id,
    required this.username,
    this.profilePhoto,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profilePhoto: json['profilePhoto'] as String?,
    );
  }

  @override
  String toString() => 'FollowModel(id: $id, username: $username)';
}
