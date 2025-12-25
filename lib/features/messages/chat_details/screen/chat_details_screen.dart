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
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/features/payment/payment_screen.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({super.key});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final controller = Get.find<MessagesController>();
  final dynamic arguments = Get.arguments;
  late ScrollController _scrollController;
  final ImagePicker _imagePicker = ImagePicker();
  final selectedFiles = <String>[].obs;

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
    selectedFiles.clear();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        selectedFiles.add(image.path);
        print('📎 File selected: ${image.path}');
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      Get.snackbar('Error', 'Failed to pick file');
    }
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
                      // GestureDetector(
                      //   onTap: controller.toggleSidebar,
                      //   child: Icon(Icons.more_vert, color: Colors.white),
                      // ),
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
                              child: Column(
                                crossAxisAlignment: isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  // Service info card (if message has service)
                                  if (msgItem.serviceId != null &&
                                      msgItem.service != null)
                                    Container(
                                      margin: EdgeInsets.only(
                                        bottom: 8,
                                        left: isMine ? 40 : 0,
                                        right: isMine ? 0 : 40,
                                      ),
                                      padding: EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey[700]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title with service name and price
                                          Text(
                                            '${msgItem.service!.serviceName} - \$${msgItem.service!.price}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          // Delivery date
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                color: Colors.white70,
                                                size: 14,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Delivery: Oct 26, 2025',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          // Status
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.orange,
                                                size: 14,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Status: Payment Pending',
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          // Pay Now button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.redColor,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 10,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              onPressed: () {
                                                Get.to(() => PaymentPage(),arguments: msgItem);

                                                Get.snackbar(
                                                  'Payment',
                                                  'Processing payment for ${msgItem.service!.serviceName}',
                                                  backgroundColor:
                                                      AppColors.redColor,
                                                  colorText: Colors.white,
                                                );
                                              },
                                              child: Text(
                                                'Pay Now',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Regular message - only show if content is not empty
                                  if (msgItem.content.trim().isNotEmpty)
                                    Container(
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
                                  // Files display
                                  if (msgItem.files.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Attachments (${msgItem.files.length})',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: msgItem.files.map((file) {
                                              final fileName = file
                                                  .split('/')
                                                  .last;
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[700],
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.image,
                                                      color: Colors.white70,
                                                      size: 14,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        fileName.length > 20
                                                            ? '${fileName.substring(0, 17)}...'
                                                            : fileName,
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 11,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                }),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    // Selected files preview
                    Obx(() {
                      if (selectedFiles.isEmpty) {
                        return SizedBox.shrink();
                      }
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedFiles.length,
                            itemBuilder: (context, index) {
                              final fileName = selectedFiles[index]
                                  .split('/')
                                  .last;
                              return Container(
                                margin: EdgeInsets.only(right: 8),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.redColor,
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.white70,
                                          size: 24,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          fileName.length > 15
                                              ? '${fileName.substring(0, 12)}...'
                                              : fileName,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          selectedFiles.removeAt(index);
                                          print('🗑️ File removed: $fileName');
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.redColor,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.all(2),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                    // Message input row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickFile,
                          child: Image.asset(
                            Iconpath.cekol,
                            height: 20,
                            width: 20,
                          ),
                        ),
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
                          icon: Image.asset(
                            Iconpath.send,
                            height: 20,
                            width: 20,
                          ),
                          onPressed: () {
                            controller.sendMessage(
                              recipientId: recipientId,
                              content: controller.messageController.text,
                              files: selectedFiles.isNotEmpty
                                  ? selectedFiles.toList()
                                  : null,
                            );
                            controller.messageController.clear();
                            selectedFiles.clear();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
          // Obx(
          //   () => controller.showSidebar.value
          //       ? Positioned(
          //           top: 100,
          //           right: 0,
          //           width: 220,
          //           height: 300,
          //           child: Material(
          //             elevation: 5,
          //             color: Colors.transparent,
          //             child: Container(
          //               decoration: BoxDecoration(
          //                 color: Colors.grey[850],
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //               child: Column(
          //                 children: [
          //                   ListTile(
          //                     title: Text(
          //                       '📎 Send File',
          //                       style: TextStyle(color: Colors.white),
          //                     ),
          //                     onTap: () {
          //                       showDialog(
          //                         context: context,
          //                         builder: (_) => const SendFileDialogWidget(),
          //                       );
          //                     },
          //                   ),
          //
          //                   Divider(color: Colors.white24, height: 2),
          //                   ListTile(
          //                     title: Text(
          //                       '💵 Make Payment',
          //                       style: TextStyle(color: Colors.white),
          //                     ),
          //                     onTap: () {
          //                       showDialog(
          //                         context: context,
          //                         builder: (context) => PaymentDialogWidget(),
          //                       );
          //                     },
          //                   ),
          //                   Divider(color: Colors.white24, height: 2),
          //                   ListTile(
          //                     title: Text(
          //                       '📅 Set Date',
          //                       style: TextStyle(color: Colors.white),
          //                     ),
          //                     onTap: () {
          //                       showDialog(
          //                         context: context,
          //                         builder: (context) => SetDateWidget(),
          //                       );
          //                     },
          //                   ),
          //                   Divider(color: Colors.white24, height: 2),
          //                   ListTile(
          //                     title: Text(
          //                       '🛒 View Order Details',
          //                       style: TextStyle(color: Colors.white),
          //                     ),
          //                     onTap: () {
          //                       showDialog(
          //                         context: context,
          //                         builder: (context) =>
          //                             ViewOrderDetailsWidget(),
          //                       );
          //                     },
          //                   ),
          //                   Divider(color: Colors.white24, height: 2),
          //                   ListTile(
          //                     title: Text(
          //                       '❌ Cancel Deal',
          //                       style: TextStyle(color: Colors.white),
          //                     ),
          //                     onTap: () {
          //                       showDialog(
          //                         context: context,
          //                         builder: (context) => CancelDealWidget(),
          //                       );
          //                     },
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         )
          //       : SizedBox.shrink(),
          // ),
        ],
      ),
    );
  }
}
