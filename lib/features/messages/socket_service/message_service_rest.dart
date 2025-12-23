import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';

class MessageServiceRest {
  NetworkClient networkClient;

  MessageServiceRest({required this.networkClient});

  /// GET /private-chat - Get all conversations with the last message
  Future<ChatListResponse> fetchMessages() async {
    final response = await networkClient.getRequest(url: Endpoint.allChats);

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      return ChatListResponse.fromJson(response.responseData!);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  /// GET /private-chat/:conversationId - Get full conversation + all messages
  Future<FullConversationResponse> getConversation(
    String conversationId,
  ) async {
    final response = await networkClient.getRequest(
      url: Endpoint.getChat(conversationId),
    );

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      return FullConversationResponse.fromJson(response.responseData!);
    } else {
      throw Exception('Failed to load conversation');
    }
  }

  /// POST /private-chat/send-message/:recipientId - Send message
  Future<MessageResponse> sendMessageRest({
    required String recipientId,
    required String content,
    String? serviceId,
    List<String>? files,
  }) async {
    final payload = {
      'recipientId': recipientId,
      'content': content,
      if (serviceId != null) 'serviceId': serviceId,
      if (files != null && files.isNotEmpty) 'files': files,
    };

    final response = await networkClient.postRequest(
      url: Endpoint.sendMessage(recipientId),
      body: payload,
    );

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      return MessageResponse.fromJson(response.responseData!);
    } else {
      throw Exception('Failed to send message');
    }
  }

  /// POST /private-chat/make-private-message-read/:messageId - Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    final response = await networkClient.postRequest(
      url: Endpoint.markMessageAsRead(messageId),
      body: {},
    );

    if (!(response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201))) {
      throw Exception('Failed to mark message as read');
    }
  }

  /// DELETE /private-chat/:conversationId - Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    final response = await networkClient.deleteRequest(
      Endpoint.deleteConversation(conversationId),
    );

    if (!(response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201))) {
      throw Exception('Failed to delete conversation');
    }
  }
}

class MessageResponse {
  final bool? success;
  final String? message;
  final ChatMessage? data;

  MessageResponse({this.success, this.message, this.data});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? ChatMessage.fromJson(json['data']) : null,
    );
  }
}

class FullConversationResponse {
  final bool? success;
  final String? message;
  final FullConversation? data;

  FullConversationResponse({this.success, this.message, this.data});

  factory FullConversationResponse.fromJson(Map<String, dynamic> json) {
    return FullConversationResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? FullConversation.fromJson(json['data'])
          : null,
    );
  }
}

class FullConversation {
  final String? conversationId;
  final List<ChatParticipant>? participants;
  final List<ChatMessage>? messages;

  FullConversation({this.conversationId, this.participants, this.messages});

  factory FullConversation.fromJson(Map<String, dynamic> json) {
    return FullConversation(
      conversationId: json['conversationId'] as String?,
      participants: (json['participants'] as List?)
          ?.map((e) => ChatParticipant.fromJson(e))
          .toList(),
      messages: (json['messages'] as List?)
          ?.map((e) => ChatMessage.fromJson(e))
          .toList(),
    );
  }
}
