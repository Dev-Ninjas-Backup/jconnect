import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/features/messages/chat_details/controller/chat_details_controller.dart';
import 'package:jconnect/features/messages/chat_details/widgets/add_service_bottom_sheet.dart';
import 'package:jconnect/features/messages/chat_details/widgets/chat_selected_files_preview.dart';

class ChatInputBar extends StatelessWidget {
  final String recipientId;
  final ChatDetailsController controller;

  const ChatInputBar({
    super.key,
    required this.recipientId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          // Selected files preview
          ChatSelectedFilesPreview(controller: controller),

          // Message input row with voice recording support
          Obx(() {
            if (controller.isRecording.value) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.redColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.formatDuration(controller.recordDuration.value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: controller.cancelRecording,
                      tooltip: 'Cancel',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: AppColors.redColor,
                        size: 20,
                      ),
                      onPressed: () =>
                          controller.stopAndSendVoice(recipientId),
                      tooltip: 'Send Voice Message',
                    ),
                  ],
                ),
              );
            }

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showAddServiceSheet(
                      context,
                      controller.addCustomServiceController,
                      recipientId: recipientId,
                    );
                  },
                  child: const Icon(
                    Icons.file_copy_sharp,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),

                GestureDetector(
                  onTap: controller.pickFile,
                  child: Image.asset(
                    Iconpath.cekol,
                    height: 20,
                    width: 20,
                  ),
                ),
                const SizedBox(width: 10),

                GestureDetector(
                  onTap: controller.startRecording,
                  child: const Icon(
                    Icons.mic_none_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: controller.messagesController.messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.grey[900],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white38),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Image.asset(
                    Iconpath.send,
                    height: 20,
                    width: 20,
                  ),
                  onPressed: () {
                    final text = controller.messagesController.messageController.text;
                    final files = controller.selectedFiles.isNotEmpty
                        ? controller.selectedFiles.toList()
                        : null;
                    controller.messagesController.sendMessage(
                      recipientId: recipientId,
                      content: text,
                      files: files,
                    );
                    controller.messagesController.messageController.clear();
                    controller.selectedFiles.clear();
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
