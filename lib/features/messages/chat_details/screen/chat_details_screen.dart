import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/messages/chat_details/widgets/cancel_deal_widget.dart';
import 'package:jconnect/features/messages/chat_details/widgets/payment_dailog_widget.dart';
import 'package:jconnect/features/messages/chat_details/widgets/send_file_dailog_widget.dart';
import 'package:jconnect/features/messages/chat_details/widgets/set_date_widget.dart';
import 'package:jconnect/features/messages/chat_details/widgets/view_oder_details_widget.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({super.key});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final controller = Get.find<MessagesController>();
  final dynamic msg = Get.arguments;

  @override
  void initState() {
    super.initState();
    if (msg != null) {
      controller.initConversation(
        conversationId: msg.chatId ?? '',
        initialMessages: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          msg.participant?.profilePhoto ?? '',
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.participant.fullName ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Active now',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: controller.toggleSidebar,
                        child: Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'You started a chat with ${msg.participant.fullName ?? ''}',
                      style: getTextStyle(
                        fontsize: 12,
                        fontweight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.redColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.messages[index].content,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Image.asset(Iconpath.cekol, height: 20, width: 20),
                    SizedBox(width: 12),
                    Image.asset(Iconpath.dollar, height: 20, width: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.messageController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.grey[900],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(Iconpath.send, height: 20, width: 20),
                      onPressed: () {
                        controller.sendMessage(
                          recipientId: msg.participant.id ?? "",
                          content: controller.messageController.text,
                        );
                        controller.messageController.clear();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
          Obx(
            () => controller.showSidebar.value
                ? Positioned(
                    top: 100,
                    right: 0,
                    width: 220,
                    height: 300,
                    child: Material(
                      elevation: 5,
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                '📎 Send File',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const SendFileDialogWidget(),
                                );
                              },
                            ),

                            Divider(color: Colors.white24, height: 2),
                            ListTile(
                              title: Text(
                                '💵 Make Payment',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => PaymentDialogWidget(),
                                );
                              },
                            ),
                            Divider(color: Colors.white24, height: 2),
                            ListTile(
                              title: Text(
                                '📅 Set Date',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => SetDateWidget(),
                                );
                              },
                            ),
                            Divider(color: Colors.white24, height: 2),
                            ListTile(
                              title: Text(
                                '🛒 View Order Details',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ViewOrderDetailsWidget(),
                                );
                              },
                            ),
                            Divider(color: Colors.white24, height: 2),
                            ListTile(
                              title: Text(
                                '❌ Cancel Deal',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => CancelDealWidget(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
