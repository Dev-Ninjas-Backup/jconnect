import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/utils/image_helper.dart';

class ChatDetailsAppBar extends StatelessWidget {
  final dynamic chatParticipant;
  final String senderUsername;
  final VoidCallback? onBackPressed;

  const ChatDetailsAppBar({
    super.key,
    required this.chatParticipant,
    required this.senderUsername,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = (chatParticipant?.username != null &&
            chatParticipant.username!.trim().isNotEmpty)
        ? chatParticipant.username!
        : (senderUsername.isNotEmpty ? senderUsername : '');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBackPressed ?? () => Get.back(),
              child: Image.asset(Iconpath.backIcon,height: 36.h,width: 36.w),
           //   child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundImage: getSafeImageProvider(
                chatParticipant?.profilePhoto,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Active now',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
