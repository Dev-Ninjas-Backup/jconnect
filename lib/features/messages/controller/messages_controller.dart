// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:uuid/uuid.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/features/messages/socket_service/message_service_rest.dart';
import 'package:jconnect/features/messages/socket_service/message_socket_service.dart';

class MessagesController extends GetxController {
  MessageServiceRest messageServiceRest = MessageServiceRest(
    networkClient: NetworkClient(
      onUnAuthorize: () {
        print("Unauthorized access - Messages");
      },
    ),
  );

  // SharedPreferences helper for auth token management
  final SharedPreferencesHelperController _prefHelper =
      Get.find<SharedPreferencesHelperController>();

  var messageController = TextEditingController();
  var showSidebar = false.obs;

  var pickedFile = Rxn<File>();

  final ImagePicker _picker = ImagePicker();

  void toggleSidebar() {
    showSidebar.value = !showSidebar.value;
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedFile.value = File(image.path);
    }
  }

  var allChats = <ChatItem>[].obs;

  Future<void> fetchallchatMethod() async {
    try {
      final resp = await messageServiceRest.fetchMessages();
      allChats.assignAll(resp.data ?? []);
      print(
        "===================Fetched  msg length: ${allChats.length} ===========",
      );
    } catch (e) {
      print('❌ Error fetching messages: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize socket connection and load conversation list on startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await initializeSocketConnection();
        await fetchallchatMethod(); // Load existing conversations
        print('✅ MessagesController initialized successfully');
      } catch (e) {
        print('❌ Failed to initialize MessagesController: $e');
        // Fallback to just loading conversations without socket
        fetchallchatMethod();
      }
    });
  }

  final MessageSocketService _socket = MessageSocketService();

  /// Reactive message list for current conversation
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// Active conversation id
  String? _conversationId;

  /// Logged-in user id
  String? _myUserId;

  /* -------------------- Socket Lifecycle -------------------- */

  void connectSocket({required String token, required String userId}) {
    _myUserId = userId;

    _socket.connect(token: token, onNewMessage: _handleIncomingMessage);
  }

  /// Initialize socket connection with proper authentication
  Future<void> initializeSocketConnection() async {
    try {
      // Get auth token from SharedPreferencesHelper
      final token = await _prefHelper
          .getAccessRowToken(); // Raw token without Bearer prefix
      final userId = await _prefHelper.getUserId();

      if (token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty) {
        // Initialize user ID for message handling
        _myUserId = userId;

        // Connect socket with authentication
        connectSocket(token: token, userId: userId);
        print('✅ Socket connected with authenticated user: $userId');
      } else {
        throw Exception('No authentication token or user ID available');
      }
    } catch (e) {
      print('❌ Failed to initialize socket connection: $e');
      // You might want to handle logout or redirect to login
    }
  }

  /// Initialize user ID if not set
  void initUserId(String userId) {
    if (_myUserId == null || _myUserId!.isEmpty) {
      _myUserId = userId;
    }
  }

  @override
  void onClose() {
    _socket.disconnect();
    super.onClose();
  }

  /* -------------------- Conversation -------------------- */

  /// Initialize existing conversation from API
  Future<void> initConversationFromAPI({required String conversationId}) async {
    try {
      _conversationId = conversationId;

      // Preserve any optimistic messages (temp messages that haven't been confirmed)
      final optimisticMessages = messages
          .where((m) => m.id.startsWith('temp_'))
          .toList();

      print('🔄 Loading conversation from API: $conversationId');
      print('💾 Preserving ${optimisticMessages.length} optimistic messages');

      // Fetch conversation from API
      final conversationResponse = await messageServiceRest
          .getSingleConversation(conversationId);

      // Clear and add API messages
      messages.clear();
      messages.addAll(conversationResponse.messages);

      // Re-add optimistic messages at the end
      for (final optMsg in optimisticMessages) {
        // Check if this optimistic message was already returned by API
        final exists = messages.any(
          (m) =>
              m.content == optMsg.content &&
              m.senderId == optMsg.senderId &&
              m.createdAt.difference(optMsg.createdAt).inSeconds.abs() < 10,
        );
        if (!exists) {
          messages.add(optMsg);
          print('🔄 Re-added optimistic message: ${optMsg.content}');
        }
      }

      print(
        '✅ Loaded ${conversationResponse.messages.length} messages from API + ${optimisticMessages.length} optimistic',
      );

      // Also emit socket event to ensure real-time connection for this conversation
      _socket.loadConversation(conversationId: conversationId);
    } catch (e) {
      print('❌ Error loading conversation from API: $e');
      // Fallback to socket-only loading
      _socket.loadConversation(conversationId: conversationId);
    }
  }

  /// Initialize new conversation with a recipient
  void initNewConversation({required String recipientId}) {
    _conversationId = null; // No existing conversation
    _recipientId = recipientId;
    messages.clear();
  }

  /// Current recipient ID for new conversations
  String? _recipientId;

  /* -------------------- Messaging -------------------- */

  void _handleIncomingMessage(dynamic data) {
    print('📩 Received incoming data: $data');
    try {
      // Check if this is a full conversation response
      if (data is Map) {
        // Handle full conversation data (from private:single_conversation)
        if (data.containsKey('conversationId') &&
            data.containsKey('messages')) {
          final conversationId = data['conversationId'] as String?;
          final messagesList = data['messages'] as List?;

          if (conversationId == _conversationId && messagesList != null) {
            final conversationMessages = messagesList
                .map(
                  (msgData) =>
                      ChatMessage.fromJson(msgData as Map<String, dynamic>),
                )
                .toList();

            // Clear and add all messages for this conversation
            messages.clear();
            messages.addAll(conversationMessages);

            print(
              '✅ Loaded ${conversationMessages.length} messages for conversation $conversationId',
            );
            return;
          }
        }

        // Handle conversation list updates
        if (data.containsKey('data') && data['data'] is List) {
          // This might be a conversation list update
          print('📄 Received conversation list update');
          return;
        }
      }

      // Handle single message
      final ChatMessage message = ChatMessage.fromJson(data);
      print(
        '✅ Parsed single message: ${message.content} from ${message.senderId}',
      );

      // Update conversation list (last message + move to top)
      _updateChatListWithMessage(message);

      // If this conversation is active, add to messages shown in details
      if (message.conversationId == _conversationId) {
        // Check if message already exists (by ID or content+sender+time)
        final existingIndex = messages.indexWhere(
          (m) =>
              m.id == message.id ||
              (m.content == message.content &&
                  m.senderId == message.senderId &&
                  m.createdAt.difference(message.createdAt).inSeconds.abs() <
                      5),
        );

        if (existingIndex == -1) {
          // Remove any matching optimistic message first
          messages.removeWhere(
            (m) =>
                m.id.startsWith('temp_') &&
                m.content == message.content &&
                m.senderId == message.senderId,
          );

          messages.add(message);
          print(
            '📝 Added new message to active conversation: ${message.content}',
          );
        } else {
          print(
            '🔄 Message already exists, skipping duplicate (index: $existingIndex)',
          );
        }
      } else {
        print(
          '📭 Message for different conversation: ${message.conversationId} vs $_conversationId',
        );
      }

      print('📊 Current messages count: ${messages.length}');
    } catch (e) {
      print('❌ Error parsing incoming data: $e');
      print('📄 Raw data type: ${data.runtimeType}');
      print('📄 Raw data: $data');
    }
  }

  void sendMessage({
    required String recipientId,
    required String content,
    String? serviceId,
    List<String>? files,
  }) async {
    if (content.trim().isEmpty && (files == null || files.isEmpty)) return;

    // Ensure user ID is set
    if (_myUserId == null || _myUserId!.isEmpty) {
      print('❌ Cannot send message: User ID not available');
      return;
    }

    // Use the provided recipientId for new conversations or stored recipientId
    final targetRecipientId = recipientId.isNotEmpty
        ? recipientId
        : _recipientId;

    if (targetRecipientId == null || targetRecipientId.isEmpty) {
      print("❌ Error: No recipient ID available");
      return;
    }

    // Create optimistic message with unique temp ID
    final tempId = 'temp_${const Uuid().v4()}';
    final localMessage = ChatMessage(
      id: tempId,
      content: content.trim(),
      files: files ?? [],
      createdAt: DateTime.now(),
      senderId: _myUserId!,
      conversationId: _conversationId ?? '',
      serviceId: serviceId,
      service: null,
      sender: SenderInfo(id: _myUserId!, fullName: 'You', profilePhoto: null),
    );

    // Add to UI immediately
    messages.add(localMessage);
    _updateChatListWithMessage(localMessage);
    print('📤 Added optimistic message: ${localMessage.content} (ID: $tempId)');

    try {
      // Send via API first
      final sentMessage = await messageServiceRest.sendMessage(
        recipientId: targetRecipientId,
        content: content.trim(),
        serviceId: serviceId,
        files: files,
      );

      // Replace optimistic message with real message from API
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = sentMessage;
        print('✅ Replaced optimistic message with API response');
      }

      // Also send via socket for real-time delivery to other clients
      _socket.sendMessage(
        recipientId: targetRecipientId,
        content: content.trim(),
        serviceId: serviceId,
        files: files,
      );

      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Error sending message via API: $e');
      // Keep optimistic message but mark it as failed/pending
      // You could add a status field to ChatMessage to show retry option

      // Try socket-only as fallback
      _socket.sendMessage(
        recipientId: targetRecipientId,
        content: content.trim(),
        serviceId: serviceId,
        files: files,
      );
    }
  }

  void _updateChatListWithMessage(ChatMessage message) {
    try {
      final lastMsg = LastMessage(
        id: message.id,
        content: message.content,
        createdAt: message.createdAt.toIso8601String(),
        sender: MessageSender(
          id: message.sender.id,
          profilePhoto: message.sender.profilePhoto,
          fullName: message.sender.fullName,
        ),
      );

      final idx = allChats.indexWhere(
        (c) => c.chatId == message.conversationId,
      );
      if (idx != -1) {
        final existing = allChats[idx];
        final updated = ChatItem(
          type: existing.type,
          chatId: existing.chatId,
          participant: existing.participant,
          lastMessage: lastMsg,
          updatedAt: lastMsg.createdAt,
        );
        // move to top
        allChats.removeAt(idx);
        allChats.insert(0, updated);
      } else {
        final participant = ChatParticipant(
          id: message.senderId,
          profilePhoto: message.sender.profilePhoto,
          fullName: message.sender.fullName,
        );
        final newChat = ChatItem(
          type: 'private',
          chatId: message.conversationId,
          participant: participant,
          lastMessage: lastMsg,
          updatedAt: lastMsg.createdAt,
        );
        allChats.insert(0, newChat);
      }
      allChats.refresh();
    } catch (e) {
      print('Failed to update chat list: $e');
    }
  }

  /* -------------------- Helpers -------------------- */

  bool isMyMessage(ChatMessage message) {
    if (_myUserId == null || _myUserId!.isEmpty) {
      print('❌ User ID not available - ensure socket is properly initialized');
      return false;
    }
    final result = message.senderId == _myUserId;
    print(
      '🔍 Checking message from ${message.senderId} vs myUserId: $_myUserId = $result',
    );
    return result;
  }

  /// 🔹 Delete confirmation dialog (bottom sheet style)
  void showDeleteDialog(BuildContext context, dynamic msg) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Get.bottomSheet(
      Container(
        height: screenHeight * 0.6,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.09,
          vertical: screenHeight * 0.09,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete icon with circular background
            SizedBox(
              height: screenHeight * 0.1,
              width: screenHeight * 0.1,
              child: Center(
                child: Container(
                  height: screenHeight * 0.08,
                  width: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: AppColors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      Iconpath.reddelete,
                      height: screenHeight * 0.035,
                      width: screenHeight * 0.035,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.015),
            Text(
              "Are you sure you want to delete this message?",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontsize: screenHeight * 0.025,
                fontweight: FontWeight.w600,
                color: AppColors.backGroundColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              "The message will be deleted from this device",
              style: getTextStyle(
                fontsize: screenHeight * 0.014,
                fontweight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.09),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(screenWidth * 0.35, screenHeight * 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    "Cancel",
                    style: getTextStyle(
                      fontsize: 14,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE7E7E7),
                    foregroundColor: Colors.black,
                    minimumSize: Size(screenWidth * 0.35, screenHeight * 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // remove from allChats if present, otherwise try messages
                    try {
                      if (allChats.contains(msg)) {
                        allChats.remove(msg);
                      } else {
                        messages.remove(msg);
                      }
                    } catch (_) {
                      // fallback: if msg has an id, remove by matching id
                      if (msg != null) {
                        final id = msg is Map ? msg['id'] : (msg.id ?? null);
                        if (id != null) {
                          allChats.removeWhere(
                            (c) =>
                                c.chatId == id ||
                                c.lastMessage?.id == id ||
                                c.participant?.id == id,
                          );
                          messages.removeWhere((m) => m.id == id);
                        }
                      }
                    }

                    Get.back();
                  },
                  child: Text(
                    "Delete",
                    style: getTextStyle(
                      fontsize: 14,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
