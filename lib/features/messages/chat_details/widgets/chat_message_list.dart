import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/messages/chat_details/controller/chat_details_controller.dart';
import 'package:jconnect/features/messages/chat_details/widgets/chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final ChatDetailsController controller;

  const ChatMessageList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = controller.messagesController.messages;
      if (messages.isEmpty) {
        return const Center(
          child: Text(
            'No messages yet\nSend a message to start the conversation',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msgItem = messages[index];
          final isMine = controller.messagesController.isMyMessage(msgItem);

          return ChatMessageBubble(
            msgItem: msgItem,
            isMine: isMine,
            controller: controller,
          );
        },
      );
    });
  }
}
