import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';

class MessageServiceRest {
  NetworkClient networkClient;

  MessageServiceRest({required this.networkClient});

  Future<ChatListResponse> fetchMessages() async {
    final response = await networkClient.getRequest(url: Endpoint.allChats);

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      return ChatListResponse.fromJson(response.responseData!);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  /// Get single conversation with all messages
  Future<ConversationResponse> getSingleConversation(
    String conversationId,
  ) async {
    final response = await networkClient.getRequest(
      url: '${Endpoint.getSingleChat}/$conversationId',
    );

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      return ConversationResponse.fromJson(response.responseData!);
    } else {
      throw Exception('Failed to load conversation: ${response.errorMessage}');
    }
  }

  /// Send message to recipient
  Future<ChatMessage> sendMessage({
    required String recipientId,
    required String content,
    String? serviceId,
    List<String>? files,
  }) async {
    final response = await networkClient.postRequest(
      url: '${Endpoint.sendMessage}/$recipientId',
      body: {
        'content': content,
        if (serviceId != null) 'serviceId': serviceId,
        if (files != null) 'files': files,
      },
    );

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      return ChatMessage.fromJson(response.responseData!);
    } else {
      throw Exception('Failed to send message: ${response.errorMessage}');
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    final response = await networkClient.postRequest(
      url: '${Endpoint.markMessageRead}/$messageId',
      body: {},
    );

    if (!response.isSuccess ||
        (response.statusCode != 200 && response.statusCode != 201)) {
      throw Exception(
        'Failed to mark message as read: ${response.errorMessage}',
      );
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    final response = await networkClient.deleteRequest(
      '${Endpoint.getSingleChat}/$conversationId',
    );

    if (!response.isSuccess ||
        (response.statusCode != 200 && response.statusCode != 201)) {
      throw Exception(
        'Failed to delete conversation: ${response.errorMessage}',
      );
    }
  }
}

/// Response model for single conversation
class ConversationResponse {
  final String conversationId;
  final List<ParticipantInfo> participants;
  final List<ChatMessage> messages;

  ConversationResponse({
    required this.conversationId,
    required this.participants,
    required this.messages,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      conversationId: json['conversationId'] ?? '',
      participants: (json['participants'] as List? ?? [])
          .map((p) => ParticipantInfo.fromJson(p))
          .toList(),
      messages: (json['messages'] as List? ?? [])
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }
}

/// Participant info model
class ParticipantInfo {
  final String id;
  final String fullName;
  final String? profilePhoto;

  ParticipantInfo({
    required this.id,
    required this.fullName,
    this.profilePhoto,
  });

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) {
    return ParticipantInfo(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      profilePhoto: json['profilePhoto'] ?? json['profile_photo'],
    );
  }
}
