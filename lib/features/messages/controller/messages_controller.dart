// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/features/messages/socket_service/message_service_rest.dart';
import 'package:jconnect/features/messages/socket_service/message_socket_service.dart';

class MessagesController extends GetxController {
  MessageServiceRest messageServiceRest = MessageServiceRest(
    networkClient: NetworkClient(
      onUnAuthorize: () {
        print("Unauthorized access - Messages");
      },
    ),
  );

  var allChats = <ChatItem>[].obs;

  Future<void> fetchallchatMethod() async {
    try {
      final resp = await messageServiceRest.fetchMessages();
      allChats.assignAll(resp.data ?? []);
      print("===================Fetched  msg length: ${allChats.length} ===========");
    } catch (e) {
      print('❌ Error fetching messages: $e');
    }
  }
  @override
  void onInit() {
    fetchallchatMethod();
    super.onInit();
  }

  final MessageSocketService _socket = MessageSocketService();

  /// Reactive message list for current conversation
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// Active conversation id
  String? _conversationId;

  /// Logged-in user id
  late final String _myUserId;

  /* -------------------- Socket Lifecycle -------------------- */

  void connectSocket({required String token, required String userId}) {
    _myUserId = userId;

    _socket.connect(token: token, onNewMessage: _handleIncomingMessage);
  }

  @override
  void onClose() {
    _socket.disconnect();
    super.onClose();
  }

  /* -------------------- Conversation -------------------- */

  void initConversation({
    required String conversationId,
    required List<ChatMessage> initialMessages,
  }) {
    _conversationId = conversationId;
    messages
      ..clear()
      ..addAll(initialMessages);
  }

  /* -------------------- Messaging -------------------- */

  void _handleIncomingMessage(dynamic data) {
    final ChatMessage message = ChatMessage.fromJson(data);

    // Ignore messages from other conversations
    if (message.conversationId != _conversationId) return;

    messages.add(message);
    print("message received: $data");

    print("message recevvvived: $message");
  }

  void sendMessage({
    required String recipientId,
    required String content,
    String? serviceId,
    List<String>? files,
  }) {
    if (content.trim().isEmpty && (files == null || files.isEmpty)) return;

    _socket.sendMessage(
      recipientId: recipientId,
      content: content.trim(),
      serviceId: serviceId,
      files: files,
    );
  }

  /* -------------------- Helpers -------------------- */

  bool isMyMessage(ChatMessage message) {
    return message.senderId == _myUserId;
  }



  /// 🔹 Delete confirmation dialog (bottom sheet style)
  void showDeleteDialog(BuildContext context, dynamic msg) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Get.bottomSheet(
      Container(
        height: screenHeight * 0.6,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.09,
          vertical: screenHeight * 0.09,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete icon with circular background
            SizedBox(
              height: screenHeight * 0.1,
              width: screenHeight * 0.1,
              child: Center(
                child: Container(
                  height: screenHeight * 0.08,
                  width: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: AppColors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      Iconpath.reddelete,
                      height: screenHeight * 0.035,
                      width: screenHeight * 0.035,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.015),
            Text(
              "Are you sure you want to delete this message?",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontsize: screenHeight * 0.025,
                fontweight: FontWeight.w600,
                color: AppColors.backGroundColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              "The message will be deleted from this device",
              style: getTextStyle(
                fontsize: screenHeight * 0.014,
                fontweight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.09),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(screenWidth * 0.35, screenHeight * 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    "Cancel",
                    style: getTextStyle(
                      fontsize: 14,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE7E7E7),
                    foregroundColor: Colors.black,
                    minimumSize: Size(screenWidth * 0.35, screenHeight * 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // remove from allChats if present, otherwise try messages
                    try {
                      if (allChats.contains(msg)) {
                        allChats.remove(msg);
                      } else {
                        messages.remove(msg);
                      }
                    } catch (_) {
                      // fallback: if msg has an id, remove by matching id
                      if (msg != null) {
                        final id = msg is Map ? msg['id'] : (msg.id ?? null);
                        if (id != null) {
                          allChats.removeWhere((c) =>
                              c.chatId == id ||
                              c.lastMessage?.id == id ||
                              c.participant?.id == id);
                          messages.removeWhere((m) => m.id == id);
                        }
                      }
                    }

                    Get.back();
                  },
                  child: Text(
                    "Delete",
                    style: getTextStyle(
                      fontsize: 14,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
