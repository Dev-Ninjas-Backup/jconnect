import 'package:flutter/material.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/messages/chat_details/controller/chat_details_controller.dart';
import 'package:jconnect/features/messages/chat_details/widgets/chat_service_card.dart';
import 'package:jconnect/features/messages/chat_details/widgets/voice_message_bubble_widget.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage msgItem;
  final bool isMine;
  final ChatDetailsController controller;

  const ChatMessageBubble({
    super.key,
    required this.msgItem,
    required this.isMine,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final audioFiles = msgItem.files.where((file) {
      final ext = file.split('.').last.split('?').first.toLowerCase();
      return ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'opus'].contains(ext);
    }).toList();

    final otherFiles = msgItem.files.where((file) {
      final ext = file.split('.').last.split('?').first.toLowerCase();
      return !['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'opus'].contains(ext);
    }).toList();

    final isVoiceOnlyHeader = audioFiles.isNotEmpty &&
        (msgItem.content.trim().startsWith('Voice Message'));

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Service info card (if message has service)
          if (msgItem.serviceId != null && msgItem.service != null)
            ChatServiceCard(
              msgItem: msgItem,
              isMine: isMine,
              controller: controller,
            ),

          Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Regular message - only show if content is not empty and not voice header
              if (msgItem.content.trim().isNotEmpty && !isVoiceOnlyHeader)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMine ? AppColors.redColor : Colors.grey[800],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMine
                          ? const Radius.circular(20)
                          : const Radius.circular(0),
                      bottomRight: isMine
                          ? const Radius.circular(0)
                          : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    msgItem.content,
                    style: TextStyle(
                      color: isMine ? Colors.white : Colors.white70,
                    ),
                  ),
                ),

              // Inline Messenger-style Voice Message Player
              if (audioFiles.isNotEmpty)
                ...audioFiles.map(
                  (audioUrl) => VoiceMessageBubbleWidget(
                    audioUrl: audioUrl,
                    isMine: isMine,
                  ),
                ),

              // Non-audio files display
              if (otherFiles.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attachments (${otherFiles.length})',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: otherFiles.map((file) {
                          final fileName = file.split('/').last;
                          return GestureDetector(
                            onTap: () => controller.viewFile(context, file),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.download,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      fileName.length > 20
                                          ? '${fileName.substring(0, 17)}...'
                                          : fileName,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
