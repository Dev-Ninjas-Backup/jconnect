// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jconnect/core/common/widgets/custom_snackbar.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/routes/approute.dart';
import '../controller/notification_controller.dart';
import '../model/notification_model.dart';
import 'package:jconnect/fcm_notification/fcm_notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find();
    
    // Force refresh notifications using GetX (controller guards against rapid API calls)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.forceRefreshNotifications();
    });
    
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
        if (controller.isLoading.value) {
          return Center(child: const CircularProgressIndicator(color: Colors.white,));
        }
        
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text(
              'No notifications',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final AppNotification notification =
                controller.notifications[index];

            return GestureDetector(
              onTap: () async {
                final titleLower = notification.title.toLowerCase();
                final messageLower = notification.message.toLowerCase();
                final typeLower = notification.type?.toLowerCase() ?? '';

                if (titleLower.contains('decline') || titleLower.contains('declined') ||
                    titleLower.contains('inquiry') || typeLower == 'inquiry' || typeLower == 'inquiry.create' ||
                    titleLower.contains('message') || typeLower == 'message' || typeLower == 'chat') {
                  _navigateToChat(notification);
                } else if (notification.title.contains("Service")) {
                  final artistId =
                      notification.userId ?? notification.creatorId;

                  if (artistId == null) {
                    return;
                  }

                  final artistsDetailsController = Get.put(
                    ArtistsDetailsController(
                      networkClient: NetworkClient(
                        onUnAuthorize: () {
                          if (kDebugMode) print("unauthorized");
                        },
                      ),
                    ),
                  );

                  await artistsDetailsController.fetchArtistById(artistId);
                  Get.toNamed(
                    AppRoute.artistsDetailsPage,
                    parameters: {'id': artistId},
                  );
                } else {
                  final fcmController = Get.find<FcmNotificationController>();
                  final Map<String, dynamic> data =
                      Map<String, dynamic>.from(notification.meta ?? {});
                  data['type'] = notification.type;
                  data['title'] = notification.title;
                  data['message'] = notification.message;

                  fcmController.routeFromNotificationData(
                    data: data,
                    title: notification.title,
                    body: notification.message,
                  );
                }
              },

              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
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
                              Expanded(
                                child: Text(
                                  notification.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              notification.title == "New Inquiry Received"
                                  ? GestureDetector(
                                      onTap: () => _navigateToChat(notification),
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
              ),
            );
          },
        );
      }),
    );
  }

  void _navigateToChat(AppNotification notification) {
    final messagesController = Get.find<MessagesController>();
    
    final artistId = notification.currentUser?.id ??
        notification.userId ??
        notification.creatorId ??
        notification.meta?['senderId']?.toString() ??
        notification.meta?['inquiryUserId']?.toString() ??
        notification.meta?['sender_id']?.toString() ??
        notification.meta?['sellerId']?.toString() ??
        notification.meta?['seller_id']?.toString() ??
        notification.meta?['buyerId']?.toString() ??
        notification.meta?['buyer_id']?.toString() ??
        notification.meta?['user_id']?.toString();

    if (artistId == null) {
      showGradientSnackBar(
        title: 'Error',
        message: 'Sender information not available',
      );
      return;
    }

    final existingChat = messagesController.allChats.firstWhereOrNull(
      (chat) => chat.participant?.id == artistId,
    );

    if (existingChat != null && existingChat.chatId != null) {
      Get.toNamed(
        AppRoute.chatDetailsScreen,
        arguments: {
          'chatItem': existingChat,
          'recipientId': artistId,
          'isNewConversation': false,
          'senderUsername': notification.currentUser?.username ??
              notification.currentUser?.full_name ??
              notification.meta?['senderName']?.toString() ??
              notification.meta?['senderUsername']?.toString() ??
              'User',
        },
      );
    } else {
      final chatItem = ChatItem(
        type: 'private',
        chatId: null,
        participant: ChatParticipant(
          id: artistId,
          fullName: notification.currentUser?.full_name ??
              notification.meta?['senderName']?.toString() ??
              'User',
          username: notification.currentUser?.username ??
              notification.meta?['senderUsername']?.toString(),
          profilePhoto: notification.currentUser?.profilePhoto ??
              notification.meta?['senderProfilePhoto']?.toString(),
        ),
      );
      Get.toNamed(
        AppRoute.chatDetailsScreen,
        arguments: {
          'chatItem': chatItem,
          'recipientId': artistId,
          'isNewConversation': true,
          'senderUsername': notification.currentUser?.username ??
              notification.currentUser?.full_name ??
              notification.meta?['senderName']?.toString() ??
              notification.meta?['senderUsername']?.toString() ??
              'User',
        },
      );
    }
  }

  String _formatDate(DateTime date) {
    try {
      final localDate = date.toLocal();
      return DateFormat('MMM d, yyyy · h:mm a').format(localDate);
    } catch (_) {
      return date.toString();
    }
  }
}
