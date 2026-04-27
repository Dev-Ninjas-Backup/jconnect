// class AppNotification {
//   final String? id;
//   final String? type;
//   final String title;
//   final String message;
//   final DateTime createdAt;
//   final Map<String, dynamic>? meta;
//   final String? senderId;
//   final String? senderName;
//   final String? senderProfilePhoto;

//   AppNotification({
//     this.id,
//     this.type,
//     required this.title,
//     required this.message,
//     required this.createdAt,
//     this.meta,
//     this.senderId,
//     this.senderName,
//     this.senderProfilePhoto,
//   });

//   factory AppNotification.fromJson(Map<String, dynamic> json) {
//     return AppNotification(
//       id: json['id'] as String?,
//       type: json['type'] as String?,
//       title: json['title'] ?? '',
//       message: json['message'] ?? '',
//       createdAt: DateTime.parse(json['createdAt']),
//       meta: json['metadata'],
//       senderId: json['senderId'] as String? ?? json['sender_id'] as String?,
//       senderName: json['senderName'] as String? ?? json['sender_name'] as String?,
//       senderProfilePhoto: json['senderProfilePhoto'] as String? ?? json['sender_profile_photo'] as String?,
//     );
//   }
// }

// ignore_for_file: non_constant_identifier_names, avoid_print

class AppUser {
  final String? id;
  final String? full_name;
  final String? username;
  final String? profilePhoto;

  AppUser({this.id, this.full_name, this.username, this.profilePhoto});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    print('👤 AppUser JSON: $json');
    return AppUser(
      id: json['id'] as String?,
      full_name: json['full_name'] as String?,
      username: json['username'] as String? ?? json['userName'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
    );
  }
}

class AppNotification {
  final String? id;
  final String? type;
  final String title;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic>? meta;
  final AppUser? currentUser;
  final String? userId; // userId from metadata
  final String? creatorId; // creatorId from metadata

  AppNotification({
    this.id,
    this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.meta,
    this.currentUser,
    this.userId,
    this.creatorId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Handle both 'metadata' (from HTTP) and 'meta' (from socket)
    final metadata = json['metadata'] ?? json['meta'];
    final currentUserData = metadata?['currentUser'];

    print('📱 Notification JSON metadata: $metadata');
    print('📱 Current User Data: $currentUserData');

    // Extract userId or creatorId from metadata
    final String? extractedUserId = metadata?['userId'] as String?;
    final String? extractedCreatorId = metadata?['creatorId'] as String?;

    return AppNotification(
      id: json['id'] as String?,
      type: json['type'] as String?,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      meta: metadata,
      currentUser: currentUserData != null
          ? AppUser.fromJson(currentUserData as Map<String, dynamic>)
          : null,
      userId: extractedUserId,
      creatorId: extractedCreatorId,
    );
  }
}
