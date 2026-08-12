import 'package:flutter/material.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class ChatDetailsHeaderBanner extends StatelessWidget {
  final dynamic chatParticipant;
  final String senderUsername;

  const ChatDetailsHeaderBanner({
    super.key,
    required this.chatParticipant,
    required this.senderUsername,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = (chatParticipant?.username != null &&
            chatParticipant.username!.trim().isNotEmpty)
        ? chatParticipant.username!
        : (senderUsername.isNotEmpty ? senderUsername : '');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'You started a chat with $displayName',
            style: getTextStyle(
              fontsize: 12,
              fontweight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
