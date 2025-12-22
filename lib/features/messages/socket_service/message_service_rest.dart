import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';

class MessageServiceRest {

NetworkClient networkClient;

  MessageServiceRest({required this.networkClient});


  Future<ChatListResponse> fetchMessages() async {
    final response = await networkClient.getRequest(
      url: Endpoint.allChats,
    );

    if (response.isSuccess &&
        (response.statusCode == 200 || response.statusCode == 201)) {
        return ChatListResponse.fromJson(response.responseData!);
    } else {
      throw Exception('Failed to load messages');
    }
  }

}