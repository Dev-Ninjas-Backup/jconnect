// ignore_for_file: avoid_print

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
    String? serviceRequestId,
    List<String>? files,
  }) async {
    print('🔥 [MESSAGE_SERVICE_REST] sendMessage called');
    print('🔥 [MESSAGE_SERVICE_REST] recipientId: $recipientId');
    print(
      '🔥 [MESSAGE_SERVICE_REST] recipientId type: ${recipientId.runtimeType}',
    );
    print(
      '🔥 [MESSAGE_SERVICE_REST] recipientId length: ${recipientId.length}',
    );
    print('🔥 [MESSAGE_SERVICE_REST] content: $content');
    print('🔥 [MESSAGE_SERVICE_REST] serviceId: $serviceId');
    print('🔥 [MESSAGE_SERVICE_REST] files: $files');

    // Validate recipientId
    if (recipientId.isEmpty) {
      print('❌ [MESSAGE_SERVICE_REST] recipientId is empty!');
      throw Exception('recipientId cannot be empty');
    }

    if (recipientId.trim().isEmpty) {
      print('❌ [MESSAGE_SERVICE_REST] recipientId is only whitespace!');
      throw Exception('recipientId cannot be only whitespace');
    }

    // Ensure recipientId is a proper non-null string
    final String sanitizedRecipientId = recipientId.trim();
    print(
      '🔥 [MESSAGE_SERVICE_REST] Sanitized recipientId: "$sanitizedRecipientId"',
    );
    print(
      '🔥 [MESSAGE_SERVICE_REST] Sanitized recipientId length: ${sanitizedRecipientId.length}',
    );

    final requestBody = {
      'recipientId': sanitizedRecipientId,
      'content': content,
      if (serviceId != null) 'serviceId': serviceId,
      if (serviceRequestId != null) 'serviceRequestId': serviceRequestId,
      if (files != null) 'files': files,
    };

    print('🔥 [MESSAGE_SERVICE_REST] Request body: $requestBody');
    final String endpoint = '${Endpoint.sendMessage}/$sanitizedRecipientId';
    print('🔥 [MESSAGE_SERVICE_REST] API endpoint: $endpoint');

    final response = await networkClient.postRequest(
      url: endpoint,
      body: requestBody,
    );

    print('🔥 [MESSAGE_SERVICE_REST] Response status: ${response.statusCode}');
    print('🔥 [MESSAGE_SERVICE_REST] Response success: ${response.isSuccess}');
    print('🔥 [MESSAGE_SERVICE_REST] Response data: ${response.responseData}');

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      // API response structure: {success: true, message: {...}}
      // Extract the message data from the wrapper
      final messageData = response.responseData!['message'] ?? response.responseData!;
      final chatMessage = ChatMessage.fromJson(messageData);
      print(
        '🔥 [MESSAGE_SERVICE_REST] Created ChatMessage with serviceId: ${chatMessage.serviceId}',
      );
      print(
        '🔥 [MESSAGE_SERVICE_REST] Created ChatMessage with service: ${chatMessage.service}',
      );
      return chatMessage;
    } else {
      print('❌ [MESSAGE_SERVICE_REST] Failed to send message');
      print('❌ [MESSAGE_SERVICE_REST] Status Code: ${response.statusCode}');
      print('❌ [MESSAGE_SERVICE_REST] Is Success: ${response.isSuccess}');
      print('❌ [MESSAGE_SERVICE_REST] Error Message: ${response.errorMessage}');
      print('❌ [MESSAGE_SERVICE_REST] Response Data: ${response.responseData}');
      print('❌ [MESSAGE_SERVICE_REST] Full Response: $response');
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
