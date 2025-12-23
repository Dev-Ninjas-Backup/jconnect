import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/messages/chat_details/screen/chat_details_screen.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';

class MessagesScreen extends StatelessWidget {
  final controller = Get.find<MessagesController>();

  MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        title: Text('Messages', style: getTextStyle(fontsize: 24.sp)),
        backgroundColor: AppColors.backGroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),

          SizedBox(height: 16.h),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.allChats.length,
                itemBuilder: (_, idx) {
                  final chat = controller.allChats[idx];
                  return buildSwipeItem(context, chat, idx);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSwipeItem(BuildContext context, dynamic msg, int idx) {
    double dragOffset = 0.0;
    final maxOffset = -80.0;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              dragOffset += details.delta.dx;
              if (dragOffset < maxOffset) dragOffset = maxOffset;
              if (dragOffset > 0) dragOffset = 0;
            });
          },
          onHorizontalDragEnd: (_) {
            if (dragOffset < maxOffset / 2) {
              setState(() => dragOffset = maxOffset);
            } else {
              setState(() => dragOffset = 0);
            }
          },
          child: Stack(
            children: [
              /// Delete Icon Background
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: dragOffset == 0 ? 0 : 1,
                    duration: Duration(milliseconds: 200),
                    child: Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: GestureDetector(
                        onTap: () => controller.showDeleteDialog(context, msg),
                        child: Container(
                          height: 50.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.redColor,
                            borderRadius: BorderRadius.circular(0.r),
                          ),
                          child: Align(
                            alignment: Alignment(0, -0.2),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(Iconpath.delete, height: 24),
                                SizedBox(height: 4),
                                Text(
                                  "Delete",
                                  style: getTextStyle(
                                    fontsize: 10,
                                    fontweight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Foreground Chat Row
              Transform.translate(
                offset: Offset(dragOffset, 0),

                child: GestureDetector(
                  onTap: () {
                    Get.to(() => ChatDetailsScreen(), arguments: msg);
                  },

                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundImage:
                              (msg.participant?.profilePhoto?.isNotEmpty ??
                                  false)
                              ? NetworkImage(msg.participant!.profilePhoto!)
                              : null,
                          child:
                              (msg.participant?.profilePhoto?.isEmpty ?? true)
                              ? Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          msg.participant.fullName ?? '',
                                          style: getTextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        // no deal tags for LastMessage
                                      ],
                                    ),
                                  ),
                                  Text(
                                    msg.lastMessage?.createdAt ?? '',
                                    style: TextStyle(
                                      color: Color(0xFF7E7E7E),
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                msg.lastMessage?.content ?? '',
                                style: TextStyle(
                                  color: Color(0xFFA3A3A3),
                                  fontSize: 12.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Divider(
                                color: Color(0xFF7E7E7E),
                                height: 20.h,
                                thickness: 0.9,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
