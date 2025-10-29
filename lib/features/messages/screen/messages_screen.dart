import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';


class MessagesScreen extends StatelessWidget {
  final MessagesController controller = Get.put(MessagesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: Text(
          'Messages',
          style: getTextStyle(color: Colors.white, fontsize: 24.sp),
        ),
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.white, size: 24.sp),
              onPressed: () {},
              splashRadius: 24.sp,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: MessagesTabBar(controller: controller),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              final filtered = _filterMessages(controller.selectedTab.value);
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, idx) {
                  final msg = filtered[idx];
                  return _buildMessageItem(msg);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterMessages(String tab) {
    final msgs = controller.messages;
    if (tab == 'All Chats') return msgs;
    if (tab == 'Active Deals') {
      return msgs.where((msg) => msg['activeDeal'] == true).toList();
    }
    if (tab == 'Unread') {
      return msgs.where((msg) => msg['unread'] == true).toList();
    }
    if (tab == 'Archived') {
      return msgs.where((msg) => msg['archived'] == true).toList();
    }
    return msgs;
  }

  Widget _buildMessageItem(Map msg) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundImage: AssetImage(Imagepath.profileImage),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            msg['name'],
                            style: getTextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (msg['activeDeal'] == true)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.redColor,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 2.h,
                              ),
                              child: Text(
                                'Active Deal',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (msg['completedDeal'] == true)
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF222222),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 2.h,
                              ),
                              child: Text(
                                'Completed Deal',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF7E7E7E),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      msg['time'],
                      style: TextStyle(
                        color: const Color(0xFF7E7E7E),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  msg['content'],
                  style: TextStyle(
                    color: const Color(0xFFA3A3A3),
                    fontSize: 12.sp,
                    fontWeight: msg['unread'] == true ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Divider(
                    color: const Color(0xFF7E7E7E),
                    height: 20.h,
                    thickness: 0.9,
                    endIndent: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesTabBar extends StatelessWidget {
  final MessagesController controller;
  const MessagesTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tabs = ['All Chats', 'Active Deals', 'Unread', 'Archived'];

    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isSelected = controller.selectedTab.value == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = tab,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.redColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
