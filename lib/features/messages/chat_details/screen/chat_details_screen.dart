// ignore_for_file: avoid_print

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
  final dynamic arguments = Get.arguments;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize socket connection first, then load conversation
    _initializeAndLoadConversation();

    // Listen to messages changes and scroll to bottom
    ever(controller.messages, (_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Schedule scroll after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _initializeAndLoadConversation() async {
    // Initialize socket connection if not already connected
    await _initializeSocketConnection();

    // Small delay to ensure socket connection is established
    await Future.delayed(Duration(milliseconds: 500));

    if (arguments != null) {
      if (arguments is Map) {
        // New conversation format
        final chatItem = arguments['chatItem'];
        final recipientId = arguments['recipientId'];
        final isNewConversation = arguments['isNewConversation'] ?? false;

        if (isNewConversation && recipientId != null) {
          // For new conversations, we'll start with empty messages
          // and set the recipient ID for sending messages
          controller.initNewConversation(recipientId: recipientId);
        } else if (chatItem?.chatId != null) {
          // Existing conversation - load from API
          await controller.initConversationFromAPI(
            conversationId: chatItem.chatId,
          );
        }
      } else {
        // Legacy format - existing conversation
        print('🔄 Loading existing conversation: ${arguments.chatId}');
        await controller.initConversationFromAPI(
          conversationId: arguments.chatId ?? '',
        );
      }
    }
  }

  Future<void> _initializeSocketConnection() async {
    try {
      // Use controller's method to initialize socket with proper auth
      await controller.initializeSocketConnection();
      print('✅ Socket connection initialized');
    } catch (e) {
      print('❌ Failed to initialize socket: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get participant info from arguments
    dynamic chatParticipant;
    String recipientId = '';

    if (arguments is Map) {
      chatParticipant = arguments['chatItem']?.participant;
      recipientId = arguments['recipientId'] ?? '';
    } else {
      chatParticipant = arguments?.participant;
      recipientId = chatParticipant?.id ?? '';
    }

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
                          chatParticipant?.profilePhoto ?? '',
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chatParticipant?.fullName ?? '',
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
                      'You started a chat with ${chatParticipant?.fullName ?? ''}',
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
                child: Obx(() {
                  print(
                    '🔄 UI Rebuilding - Messages count: ${controller.messages.length}',
                  );
                  return controller.messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet\nSend a message to start the conversation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final msgItem = controller.messages[index];
                            final isMine = controller.isMyMessage(msgItem);
                            print(
                              '💬 Displaying message $index: ${msgItem.content}, isMine: $isMine',
                            );

                            return Align(
                              alignment: isMine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isMine
                                      ? AppColors.redColor
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: isMine
                                        ? Radius.circular(20)
                                        : Radius.circular(0),
                                    bottomRight: isMine
                                        ? Radius.circular(0)
                                        : Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  msgItem.content,
                                  style: TextStyle(
                                    color: isMine
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                }),
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
                          recipientId: recipientId,
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
