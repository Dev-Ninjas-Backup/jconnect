import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';
import 'package:jconnect/features/messages/socket_service/message_socket_service.dart';

class MessagesController extends GetxController {
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

  final selectedTab = 'All Chats'.obs;

  var messages1 = [
    {
      'name': 'John Doe',
      'content': 'Hey there! How are you?',
      'time': '10:45 AM',
      'unread': true,
      'activeDeal': true,
      'completedDeal': false,
      'archived': false,
    },
    {
      'name': 'Alice Smith',
      'content': 'Let’s catch up later.',
      'time': 'Yesterday',
      'unread': false,
      'activeDeal': false,
      'completedDeal': true,
      'archived': false,
    },
    {
      'name': 'Michael Johnson',
      'content': 'I sent you the files.',
      'time': '9:30 AM',
      'unread': true,
      'activeDeal': false,
      'completedDeal': false,
      'archived': false,
    },
    {
      'name': 'Emma Williams',
      'content': 'Can we reschedule the meeting?',
      'time': 'Yesterday',
      'unread': false,
      'activeDeal': true,
      'completedDeal': false,
      'archived': false,
    },
    {
      'name': 'David Brown',
      'content': 'Thanks for your support!',
      'time': 'Sep 20',
      'unread': true,
      'activeDeal': false,
      'completedDeal': true,
      'archived': false,
    },
    {
      'name': 'Sophia Davis',
      'content': 'Please check the document attached.',
      'time': 'Sep 18',
      'unread': false,
      'activeDeal': false,
      'completedDeal': false,
      'archived': false,
    },
    {
      'name': 'James Wilson',
      'content': 'Looking forward to our collaboration.',
      'time': 'Sep 15',
      'unread': true,
      'activeDeal': true,
      'completedDeal': false,
      'archived': false,
    },
  ].obs;

  /// 🔹 Delete confirmation dialog (bottom sheet style)
  void showDeleteDialog(BuildContext context, Map msg) {
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
                    messages.remove(msg);
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
