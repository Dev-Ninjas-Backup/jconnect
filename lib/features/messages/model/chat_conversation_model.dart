class ChatMessage {
  final String id;
  final String content;
  final List<String> files;
  final DateTime createdAt;
  final String senderId;
  final String conversationId;
  final String? serviceId;
  final ServiceInfo? service;
  final SenderInfo sender;

  ChatMessage({
    required this.id,
    required this.content,
    required this.files,
    required this.createdAt,
    required this.senderId,
    required this.conversationId,
    this.serviceId,
    this.service,
    required this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'] ?? '',
      files: List<String>.from(json['files'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      senderId: json['senderId'],
      conversationId: json['conversationId'],
      serviceId: json['serviceId'],
      service: json['service'] != null
          ? ServiceInfo.fromJson(json['service'])
          : null,
      sender: SenderInfo.fromJson(json['sender']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'files': files,
      'createdAt': createdAt.toIso8601String(),
      'senderId': senderId,
      'conversationId': conversationId,
      'serviceId': serviceId,
      'service': service?.toJson(),
      'sender': sender.toJson(),
    };
  }
}
class SenderInfo {
  final String id;
  final String fullName;
  final String? profilePhoto;

  SenderInfo({
    required this.id,
    required this.fullName,
    this.profilePhoto,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['id'],
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      profilePhoto: json['profilePhoto'] ?? json['profile_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'profilePhoto': profilePhoto,
    };
  }
}
class ServiceInfo {
  final String id;
  final String serviceName;
  final String serviceType;
  final String? description;
  final num price;
  final String? currency;
  final String creatorId;
  final bool isPost;
  final bool isCustom;

  ServiceInfo({
    required this.id,
    required this.serviceName,
    required this.serviceType,
    this.description,
    required this.price,
    this.currency,
    required this.creatorId,
    required this.isPost,
    required this.isCustom,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: json['id'],
      serviceName: json['serviceName'],
      serviceType: json['serviceType'],
      description: json['description'],
      price: json['price'],
      currency: json['currency'],
      creatorId: json['creatorId'],
      isPost: json['isPost'] ?? false,
      isCustom: json['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'serviceType': serviceType,
      'description': description,
      'price': price,
      'currency': currency,
      'creatorId': creatorId,
      'isPost': isPost,
      'isCustom': isCustom,
    };
  }
}

