import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/messages/chat_details/controller/chat_details_controller.dart';
import 'package:jconnect/features/messages/chat_details/widgets/chat_details_app_bar.dart';
import 'package:jconnect/features/messages/chat_details/widgets/chat_details_header_banner.dart';
import 'package:jconnect/features/messages/chat_details/widgets/chat_input_bar.dart';
import 'package:jconnect/features/messages/chat_details/widgets/chat_message_list.dart';

// Re-export widgets for backward compatibility with external imports (e.g. order_details_screen.dart)
export 'package:jconnect/features/messages/chat_details/widgets/add_service_bottom_sheet.dart';
export 'package:jconnect/features/messages/chat_details/widgets/audio_player_screen.dart';
export 'package:jconnect/features/messages/chat_details/widgets/video_viewer_screen.dart';
export 'package:jconnect/features/messages/chat_details/widgets/voice_message_bubble_widget.dart';

class ChatDetailsScreen extends StatelessWidget {
  ChatDetailsScreen({super.key});

  final ChatDetailsController controller = Get.put(ChatDetailsController());

  @override
  Widget build(BuildContext context) {
    ever(controller.messagesController.messages, (_) {
      controller.scrollToBottom();
    });

    dynamic chatParticipant;
    String recipientId = '';
    String senderUsername = '';

    final args = controller.arguments;
    if (args is Map) {
      chatParticipant = args['chatItem']?.participant;
      recipientId = args['recipientId'] ?? '';
      senderUsername = args['senderUsername'] ?? '';
    } else {
      chatParticipant = args?.participant;
      recipientId = chatParticipant?.id ?? '';
      senderUsername = args?.senderUsername ?? '';
    }

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              ChatDetailsAppBar(
                chatParticipant: chatParticipant,
                senderUsername: senderUsername,
                onBackPressed: () => Get.back(),
              ),
              const SizedBox(height: 10),
              ChatDetailsHeaderBanner(
                chatParticipant: chatParticipant,
                senderUsername: senderUsername,
              ),
              Expanded(child: ChatMessageList(controller: controller)),
              ChatInputBar(recipientId: recipientId, controller: controller),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
