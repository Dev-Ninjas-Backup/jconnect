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
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      files: ((json['files'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      senderId: (json['senderId'] ?? json['sender']?['id'])?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      serviceId: json['serviceId'] is Map
          ? (json['serviceId'] as Map)['id']?.toString()
          : json['serviceId']?.toString(),
      service: json['service'] != null
          ? ServiceInfo.fromJson(json['service'])
          : null,
      sender: json['sender'] != null
          ? SenderInfo.fromJson(json['sender'])
          : SenderInfo(id: '', fullName: '', profilePhoto: null),
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

  SenderInfo({required this.id, required this.fullName, this.profilePhoto});

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['id'] is String ? json['id'] : (json['id']?.toString() ?? ''),
      fullName: (json['full_name'] ?? json['fullName'])?.toString() ?? '',
      profilePhoto:
          json['profilePhoto']?.toString() ?? json['profile_photo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'profilePhoto': profilePhoto};
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
      id: (json['id'] is String ? json['id'] : json['id']?.toString()) ?? '',
      serviceName:
          (json['serviceName'] is String
              ? json['serviceName']
              : json['serviceName']?.toString()) ??
          '',
      serviceType:
          (json['serviceType'] is String
              ? json['serviceType']
              : json['serviceType']?.toString()) ??
          '',
      description: json['description']?.toString(),
      price: (json['price'] is num)
          ? json['price']
          : (double.tryParse(json['price']?.toString() ?? '') ?? 0),
      currency: json['currency']?.toString(),
      creatorId:
          (json['creatorId'] is String
              ? json['creatorId']
              : json['creatorId']?.toString()) ??
          '',
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
