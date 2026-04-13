import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/messages/chat_details/screen/chat_details_screen.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final controller = Get.find<MessagesController>();

  @override
  void initState() {
    super.initState();
    // Refresh conversations when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchallchatMethod();
    });
  }

  String _formatDateTime(String? iso) {
    if (iso == null || iso.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final mm = dt.month.toString().padLeft(2, '0');
      final dd = dt.day.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      final hh = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      return '$mm/$dd/$yyyy, $hh:$min:$ss';
    } catch (e) {
      return iso;
    }
  }

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

  Widget buildSwipeItem(BuildContext widgetContext, dynamic msg, int idx) {
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
                        onTap: () =>
                            controller.showDeleteDialog(widgetContext, msg),
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
                    Get.to(
                      () => ChatDetailsScreen(),
                      arguments: {
                        'chatItem': msg,
                        'recipientId': msg.participant?.id ?? '',
                        'isNewConversation': false,
                      },
                    );
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
                          backgroundImage: NetworkImage(
                            msg.participant?.profilePhoto ?? '',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    msg.participant.username ?? '',
                                    style: getTextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    _formatDateTime(msg.lastMessage?.createdAt),
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
