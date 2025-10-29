import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import '../controller/support_controller.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());
    final TextEditingController textController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    void send() {
      if (textController.text.trim().isEmpty) return;
      controller.sendMessage(textController.text);
      textController.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backGroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Contact Support',
          style: getTextStyle(fontsize: 20, fontweight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final alignment = msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft;

                    return Align(
                      alignment: alignment,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        constraints: BoxConstraints(maxWidth: 260.w),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? AppColors.redAccent.withValues(alpha: .9)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          msg.message,
                          style: getTextStyle(
                            color: msg.isUser ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 12.h,
                left: 12.w,
                right: 12.w,
                top: 4.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextField(
                        controller: textController,
                        style: getTextStyle(),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: getTextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: Colors.white.withValues(alpha: .9),
                    ),
                    onPressed: send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
