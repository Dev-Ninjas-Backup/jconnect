import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/routes/approute.dart';
import '../controller/notification_controller.dart';
import '../model/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text(
              'No notifications yet',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final AppNotification notification =
                controller.notifications[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(
                      Icons.notifications,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            notification.title == "New Inquiry Received"
                                ? GestureDetector(
                                onTap: 
                                (){
                                  final messagesController =
                                    Get.find<MessagesController>();
                                  final artistId = notification.currentUser?.id;

                                  if (artistId == null) {
                                    Get.snackbar('Error', 'Sender information not available');
                                    return;
                                  }

                                  final existingChat = messagesController.allChats
                                      .firstWhereOrNull(
                                        (chat) => chat.participant?.id == artistId,
                                      );

                                  if (existingChat != null &&
                                      existingChat.chatId != null) {
                                    Get.toNamed(
                                      AppRoute.chatDetailsScreen,
                                      arguments: {
                                        'chatItem': existingChat,
                                        'recipientId': artistId,
                                        'isNewConversation': false,
                                      },
                                    );
                                  } else {
                                    final chatItem = ChatItem(
                                      type: 'private',
                                      chatId: null,
                                      participant: ChatParticipant(
                                        id: artistId,
                                        fullName: notification.currentUser?.full_name ?? 'User',
                                        profilePhoto: notification.currentUser?.profilePhoto,
                                      ),
                                    );
                                    Get.toNamed(
                                      AppRoute.chatDetailsScreen,
                                      arguments: {
                                        'chatItem': chatItem,
                                        'recipientId': artistId,
                                        'isNewConversation': true,
                                      },
                                    );
                                  }
                                }
                                
                                
                                
        
                                
                                
                                
                                
                                
                                ,
                                  child: Icon(
                                      Icons.message,
                                      color: Colors.greenAccent,
                                      size: 24,
                                    ),
                                )
                                : SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
