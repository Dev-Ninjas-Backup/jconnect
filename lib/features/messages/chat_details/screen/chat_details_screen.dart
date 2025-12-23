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
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({super.key});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final controller = Get.find<MessagesController>();
  final dynamic _argument = Get.arguments;
  late ScrollController _scrollController;
  Worker? _messagesWorker;

  ChatParticipant? _participant;

  Future<void> _initFromArgument() async {
    // Open from message list
    if (_argument is ChatItem) {
      final item = _argument;
      setState(() {
        _participant = item.participant;
      });

      if ((item.chatId ?? '').isNotEmpty) {
        await controller.initConversation(
          conversationId: item.chatId ?? '',
          initialMessages: const [],
        );
      }
      return;
    }

    // Open from artist card
    if (_argument is ArtistsModel) {
      final artist = _argument;
      final participant = ChatParticipant(
        id: artist.id,
        profilePhoto: artist.profilePhoto,
        fullName: artist.fullName,
      );

      setState(() {
        _participant = participant;
      });

      final resolved = await controller.resolveChatByParticipant(participant);
      setState(() {
        _participant = resolved.participant ?? _participant;
      });

      await controller.initConversation(
        conversationId: resolved.chatId ?? 'new_${participant.id}',
        initialMessages: const [],
      );
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _initFromArgument();

    // Auto-scroll to latest message when messages list updates
    _messagesWorker = ever(controller.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_participant == null) {
      return Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
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
                        backgroundImage:
                            (_participant?.profilePhoto?.isNotEmpty ?? false)
                            ? NetworkImage(_participant!.profilePhoto!)
                            : null,
                        child: (_participant?.profilePhoto?.isEmpty ?? true)
                            ? Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _participant?.fullName ?? '',
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
                      'You started a chat with ${_participant?.fullName ?? ''}',
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
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final msgItem = controller.messages[index];
                      final isMine = controller.isMyMessage(msgItem);

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
                              color: isMine ? Colors.white : Colors.white70,
                            ),
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
                          recipientId: _participant?.id ?? "",
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
