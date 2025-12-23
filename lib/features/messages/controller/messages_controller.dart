// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  var isLoadingChats = false.obs;

  /// Fetch all conversations with last message
  Future<void> fetchallchatMethod() async {
    try {
      isLoadingChats.value = true;
      final resp = await messageServiceRest.fetchMessages();
      allChats.assignAll(resp.data ?? []);
      print(
        "===================Fetched  msg length: ${allChats.length} ===========",
      );
    } catch (e) {
      print('❌ Error fetching messages: $e');
    } finally {
      isLoadingChats.value = false;
    }
  }

  /// Find an existing conversation for a given participant.
  ///
  /// Used when opening chat from an [ArtistsModel] where we only know the
  /// recipient user id (participant id). If not found, returns a placeholder
  /// chat with a fake id (`new_<participantId>`).
  Future<ChatItem> resolveChatByParticipant(ChatParticipant participant) async {
    // Ensure chat list is available.
    if (allChats.isEmpty && !isLoadingChats.value) {
      await fetchallchatMethod();
    }

    for (final chat in allChats) {
      if (chat.participant?.id == participant.id) {
        return chat;
      }
    }

    return ChatItem(
      type: 'private',
      chatId: 'new_${participant.id}',
      participant: participant,
      lastMessage: null,
      updatedAt: null,
    );
  }

  /// Fetch full conversation with all messages (REST API fallback)
  Future<List<ChatMessage>> fetchFullConversation(String conversationId) async {
    try {
      final resp = await messageServiceRest.getConversation(conversationId);
      return resp.data?.messages ?? [];
    } catch (e) {
      print('❌ Error fetching full conversation: $e');
      return [];
    }
  }

  @override
  void onInit() {
    _warmupMyUserIdFromPrefs();
    _connectSocketFromPrefs();
    fetchallchatMethod();
    super.onInit();
  }

  final MessageSocketService _socket = MessageSocketService();

  /// Reactive message list for current conversation
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// Loading state for a single conversation
  final isLoadingConversation = false.obs;

  /// Active conversation id
  String? _conversationId;

  /// Logged-in user id
  String? _myUserId;

  bool _socketConnectedOnce = false;

  /* -------------------- Socket Lifecycle -------------------- */

  Future<void> _connectSocketFromPrefs() async {
    if (_socketConnectedOnce && _socket.isConnected) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('access_token');
      if (stored == null || stored.isEmpty) return;

      // Token is stored as "Bearer <token>" in this app.
      final token = stored.startsWith('Bearer ') ? stored.substring(7) : stored;
      if (token.isEmpty) return;

      _socket.connect(
        token: token,
        onNewMessage: _handleIncomingMessage,
        onSuccess: (userId) {
          _myUserId = userId;
          _socket.loadAllConversations();
        },
      );
      _socketConnectedOnce = true;
    } catch (e) {
      print('❌ Failed to connect message socket: $e');
    }
  }

  void connectSocket({required String token, required String userId}) {
    _myUserId = userId;

    if (_socketConnectedOnce && _socket.isConnected) {
      return;
    }

    final cleanToken = token.startsWith('Bearer ') ? token.substring(7) : token;
    _socket.connect(
      token: cleanToken,
      onNewMessage: _handleIncomingMessage,
      onSuccess: (id) {
        _myUserId = id;
        _socket.loadAllConversations();
      },
    );
    _socketConnectedOnce = true;
  }

  @override
  void onClose() {
    _socket.disconnect();
    super.onClose();
  }

  /* -------------------- Conversation -------------------- */

  Future<void> initConversation({
    required String conversationId,
    required List<ChatMessage> initialMessages,
  }) async {
    _conversationId = conversationId;
    messages.clear();

    isLoadingConversation.value = true;

    if (initialMessages.isNotEmpty) {
      messages.addAll(initialMessages);
      await _saveMessagesToStorage(conversationId, initialMessages);
    } else {
      // If conversationId is fake (starts with "new_"), skip server fetch
      // Real messages will arrive via socket and sync the ID
      if (conversationId.startsWith('new_')) {
        final persisted = await _loadMessagesFromStorage(conversationId);
        messages.addAll(persisted);
      } else {
        // Prefer server as source-of-truth so reopening always shows history.
        final serverMessages = await fetchFullConversation(conversationId);
        if (serverMessages.isNotEmpty) {
          messages.assignAll(serverMessages);
          await _saveMessagesToStorage(conversationId, serverMessages);
        } else {
          // Fallback to cached messages if server call fails.
          final persisted = await _loadMessagesFromStorage(conversationId);
          messages.addAll(persisted);
        }
      }
    }

    isLoadingConversation.value = false;
  }

  /* -------------------- Messaging -------------------- */

  void _handleIncomingMessage(dynamic data) {
    // Check if this is a system event (conversation list, etc) vs actual message
    if (data is Map && data['type'] != null) {
      // Handle system events
      final type = data['type'] as String;
      if (type == 'conversation_list' || type == 'new_conversation') {
        try {
          final raw = data['data'];
          if (raw is List) {
            final chats = raw
                .map((e) => e is Map ? e : null)
                .whereType<Map>()
                .map((e) => ChatItem.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            allChats.assignAll(chats);
            allChats.refresh();
          }
        } catch (e) {
          print('❌ Failed to parse $type payload: $e');
        }
        return;
      }
    }

    // Handle actual message event
    try {
      final ChatMessage message = ChatMessage.fromJson(data);

      // Dedupe: if same message arrives twice (multiple listeners, retries, etc)
      final alreadyInList = messages.any((m) => m.id == message.id);
      if (alreadyInList) {
        return;
      }

      // If conversationId is a fake "new_*" ID, sync to the real one from incoming message
      if (_conversationId != null && _conversationId!.startsWith('new_')) {
        print(
          '🔄 Syncing fake conversationId from socket message: $_conversationId → ${message.conversationId}',
        );
        _conversationId = message.conversationId;
      }

      // Update conversation list (last message + move to top)
      _updateChatListWithMessage(message);

      // Cache for reopening/offline fallback
      _appendMessageToStorage(message);

      // If this conversation is active, add to messages shown in details
      if (message.conversationId == _conversationId) {
        messages.add(message);
      }

      print("✅ message received: ${message.content}");
    } catch (e) {
      print('❌ Error parsing message: $e');
    }
  }

  void sendMessage({
    required String recipientId,
    required String content,
    String? serviceId,
    List<String>? files,
  }) {
    if (content.trim().isEmpty && (files == null || files.isEmpty)) return;

    // IMPORTANT: Do NOT send via both socket and REST.
    // If you do, backend may create two different messages (two IDs) -> UI shows 2.
    if (_socket.isConnected) {
      _socket.sendMessage(
        recipientId: recipientId,
        content: content.trim(),
        serviceId: serviceId,
        files: files,
      );
      // Message will be added when server confirms via private:new_message
      return;
    }

    // Socket not connected -> fallback to REST
    _sendMessageViaRest(
      recipientId: recipientId,
      content: content.trim(),
      serviceId: serviceId,
      files: files,
    );
  }

  /// Send message via REST API
  Future<void> _sendMessageViaRest({
    required String recipientId,
    required String content,
    String? serviceId,
    List<String>? files,
  }) async {
    try {
      final resp = await messageServiceRest.sendMessageRest(
        recipientId: recipientId,
        content: content,
        serviceId: serviceId,
        files: files,
      );
      print('✅ Message sent successfully via REST API');

      final created = resp.data;
      if (created == null) return;

      // Update conversation list + cache
      _updateChatListWithMessage(created);
      _appendMessageToStorage(created);

      // If conversationId is a fake "new_*" ID, sync to the real one from the response
      if (_conversationId != null && _conversationId!.startsWith('new_')) {
        print(
          '🔄 Syncing fake conversationId to real: $_conversationId → ${created.conversationId}',
        );
        _conversationId = created.conversationId;
        // Just update the ID, don't reload (would fail fetching fake ID from server)
        // Add the message to the current view, rest will sync via socket
        final exists = messages.any((m) => m.id == created.id);
        if (!exists) {
          messages.add(created);
        }
        // Cache to new ID for next time
        await _saveMessagesToStorage(created.conversationId, messages);
        return;
      }

      // If this chat is currently open, show it
      if (created.conversationId == _conversationId) {
        final exists = messages.any((m) => m.id == created.id);
        if (!exists) {
          messages.add(created);
        }
      }
    } catch (e) {
      print('❌ Error sending message via REST API: $e');
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await messageServiceRest.markMessageAsRead(messageId);
      print('✅ Message marked as read');
    } catch (e) {
      print('❌ Error marking message as read: $e');
    }
  }

  /// Delete conversation
  Future<void> deleteConversationMethod(String conversationId) async {
    try {
      await messageServiceRest.deleteConversation(conversationId);
      // Also remove from UI
      allChats.removeWhere((c) => c.chatId == conversationId);
      print('✅ Conversation deleted successfully');
    } catch (e) {
      print('❌ Error deleting conversation: $e');
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

  /* -------------------- Persistence -------------------- */

  String _storageKeyFor(String conversationId) => 'conv_msgs_$conversationId';

  Future<void> _saveMessagesToStorage(
    String conversationId,
    List<ChatMessage> msgs,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKeyFor(conversationId);
      final list = msgs.map((m) => m.toJson()).toList();
      await prefs.setString(key, jsonEncode(list));
    } catch (e) {
      print('Failed to persist conversation: $e');
    }
  }

  Future<void> _appendMessageToStorage(ChatMessage msg) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKeyFor(msg.conversationId);
      final existing = prefs.getString(key);
      List<Map<String, dynamic>> list = [];
      if (existing != null) {
        final decoded = jsonDecode(existing) as List<dynamic>;
        list = decoded.cast<Map<String, dynamic>>();
      }

      final already = list.any((m) => m['id'] == msg.id);
      if (already) return;

      list.add(msg.toJson());
      await prefs.setString(key, jsonEncode(list));
    } catch (e) {
      print('Failed to persist message: $e');
    }
  }

  Future<List<ChatMessage>> _loadMessagesFromStorage(
    String conversationId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKeyFor(conversationId);
      final existing = prefs.getString(key);
      if (existing == null) return [];
      final decoded = jsonDecode(existing) as List<dynamic>;
      return decoded
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Failed to load persisted messages: $e');
      return [];
    }
  }

  /* -------------------- Helpers -------------------- */

  Future<void> _warmupMyUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _myUserId ??= prefs.getString('user_id');
    } catch (_) {
      // Ignore: we'll still work without it (isMyMessage will fall back to false)
    }
  }

  bool isMyMessage(ChatMessage message) {
    final myId = _myUserId;
    if (myId == null || myId.isEmpty) return false;
    return message.senderId == myId;
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
                        final id = msg is Map ? msg['id'] : (msg.id);
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
