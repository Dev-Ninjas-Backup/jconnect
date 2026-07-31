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

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // Refresh notifications safely exactly once when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.forceRefreshNotifications();
    });
  }

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

        if (kDebugMode) {
          print("Current Notification Length on Screen: ${controller.notifications.length}");
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

                if (notification.title.contains("Service")) {
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
                } else if (titleLower.contains('inquiry') || 
                           titleLower.contains('message') || 
                           typeLower == 'message') {
                  // Navigate to Chat Details for messages and inquiries
                  final messagesController = Get.find<MessagesController>();
                  final artistId = notification.currentUser?.id ?? notification.userId ?? notification.creatorId;

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
                            'User',
                      },
                    );
                  } else {
                    final chatItem = ChatItem(
                      type: 'private',
                      chatId: null,
                      participant: ChatParticipant(
                        id: artistId,
                        fullName: notification.currentUser?.full_name ?? 'User',
                        username: notification.currentUser?.username,
                        profilePhoto: notification.currentUser?.profilePhoto,
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
                            'User',
                      },
                    );
                  }
                } else {
                  // Fallback: Let FCM Controller handle routing (e.g. Orders, Reposts)
                  final fcmController = Get.find<FcmNotificationController>();
                  final Map<String, dynamic> data =
                      Map<String, dynamic>.from(notification.meta ?? {});
                  data['type'] = notification.type;
                  data['title'] = notification.title;
                  data['message'] = notification.message;
                  if (notification.currentUser != null) {
                    data['recipientId'] = notification.currentUser?.id;
                    data['senderUsername'] = notification.currentUser?.username;
                    data['profilePhoto'] = notification.currentUser?.profilePhoto;
                  }

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

  String _formatDate(DateTime date) {
    try {
      final localDate = date.toLocal();
      return DateFormat('MMM d, yyyy · h:mm a').format(localDate);
    } catch (_) {
      return date.toString();
    }
  }
}
