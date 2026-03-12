class ChatListResponse {
  final bool? success;
  final String? message;
  final List<ChatItem>? data;

  ChatListResponse({this.success, this.message, this.data});

  factory ChatListResponse.fromJson(Map<String, dynamic> json) {
    return ChatListResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List?)?.map((e) => ChatItem.fromJson(e)).toList(),
    );
  }
}

class ChatItem {
  final String? type;
  final String? chatId;
  final ChatParticipant? participant;
  final LastMessage? lastMessage;
  final String? updatedAt;

  ChatItem({
    this.type,
    this.chatId,
    this.participant,
    this.lastMessage,
    this.updatedAt,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      type: json['type'] as String?,
      chatId: json['chatId'] as String?,
      participant: json['participant'] != null
          ? ChatParticipant.fromJson(json['participant'])
          : null,
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'])
          : null,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class ChatParticipant {
  final String? id;
  final String? profilePhoto;
  final String? fullName;
  final String? username;

  ChatParticipant({this.id, this.profilePhoto, this.fullName, this.username});

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
    );
  }

  /// UI Safe Fallbacks
  String get displayName => fullName ?? 'Unknown User';
  String get avatar => profilePhoto ?? '';
}

class LastMessage {
  final String? id;
  final String? content;
  final String? createdAt;
  final MessageSender? sender;

  LastMessage({this.id, this.content, this.createdAt, this.sender});

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['id'] as String?,
      content: json['content'] as String?,
      createdAt: json['createdAt'] as String?,
      sender: json['sender'] != null
          ? MessageSender.fromJson(json['sender'])
          : null,
    );
  }

  /// UI Safe
  String get messagePreview => content ?? '';
}

class MessageSender {
  final String? id;
  final String? profilePhoto;
  final String? fullName;

  MessageSender({this.id, this.profilePhoto, this.fullName});

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  String get name => fullName ?? 'Unknown';
}
