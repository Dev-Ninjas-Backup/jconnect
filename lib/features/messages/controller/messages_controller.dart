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

  /// Cache of serviceId → ServiceRequestInfo so details survive conversation reloads.
  final Map<String, ServiceRequestInfo> _serviceRequestCache = {};

  void applyServiceRequest(String serviceId, ServiceRequestInfo info) {
    _serviceRequestCache[serviceId] = info;
    _patchMessagesWithCache();
  }

  /// Mark a specific message's service request as paid locally (instant UI update).
  void markMessageAsPaid(String messageId) {
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].id == messageId) {
        final existing = messages[i].serviceRequest;
        if (existing != null) {
          messages[i] = messages[i].copyWith(
            serviceRequest: existing.copyWith(isPaid: true),
          );
        }
        break;
      }
    }
  }

  void _patchMessagesWithCache() {
    if (_serviceRequestCache.isEmpty) return;
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (msg.serviceId != null &&
          _serviceRequestCache.containsKey(msg.serviceId) &&
          msg.serviceRequest == null) {
        messages[i] = msg.copyWith(serviceRequest: _serviceRequestCache[msg.serviceId]);
      }
    }
  }

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
    // Reset conversation tracking on controller initialization
    _lastLoadedConversationId = null;
    _loadedMessageIds.clear();

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

  bool _socketInitialized = false;

  /// Reactive message list for current conversation
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// Active conversation id
  String? _conversationId;

  /// Logged-in user id
  String? _myUserId;

  /// Flag to prevent duplicate conversation loads
  /// Flag to track if conversation ID has changed
  String? _lastLoadedConversationId;

  /// Set of loaded message IDs to prevent socket duplicates
  Set<String> _loadedMessageIds = {};

  static const Duration _duplicateWindow = Duration(seconds: 3);

  String _msgSignature(ChatMessage m) {
    final normalizedContent = m.content.trim();
    final files = [...m.files];
    files.sort();
    return '${m.senderId}|${m.serviceId ?? ''}|$normalizedContent|${files.join(',')}';
  }

  bool _isNearDuplicate(ChatMessage a, ChatMessage b) {
    if (_msgSignature(a) != _msgSignature(b)) return false;
    return a.createdAt.difference(b.createdAt).abs() <= _duplicateWindow;
  }

  List<ChatMessage> _dedupeConversationMessages(List<ChatMessage> input) {
    if (input.isEmpty) return const [];

    final sorted = [...input]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final seenIds = <String>{};
    final out = <ChatMessage>[];

    for (final msg in sorted) {
      if (seenIds.contains(msg.id)) {
        continue;
      }
      seenIds.add(msg.id);

      // Check recent tail for near-duplicates (covers double-save cases).
      bool dup = false;
      for (int i = out.length - 1; i >= 0 && i >= out.length - 5; i--) {
        if (_isNearDuplicate(out[i], msg)) {
          dup = true;
          break;
        }
      }
      if (!dup) {
        out.add(msg);
      }
    }

    return out;
  }

  /* -------------------- Socket Lifecycle -------------------- */

  void connectSocket({required String token, required String userId}) {
    _myUserId = userId;

    _socket.connect(token: token, onNewMessage: _handleIncomingMessage);
  }

  /// Initialize socket connection with proper authentication
  Future<void> initializeSocketConnection() async {
    try {
      // Get auth token and userId first to ensure _myUserId is always set
      final token = await _prefHelper
          .getAccessRowToken(); // Raw token without Bearer prefix
      final userId = await _prefHelper.getUserId();

      if (token != null &&
          token.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty) {
        // Always initialize user ID, even if socket is already connected
        _myUserId = userId;

        // Only connect socket if not already initialized
        if (_socketInitialized && _socket.isConnected) {
          print('✅ Socket already connected, user ID refreshed: $userId');
          return;
        }

        // Connect socket with authentication
        connectSocket(token: token, userId: userId);
        _socketInitialized = true;
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
    _socketInitialized = false;
    super.onClose();
  }

  /* -------------------- Conversation -------------------- */

  /// Initialize existing conversation from API
  Future<void> initConversationFromAPI({
    required String conversationId,
    bool force = false,
  }) async {
    try {
      // Prevent duplicate loading only if:
      // 1. Same conversation was already loaded
      // 2. AND we still have the messages in memory (not empty)
      if (!force &&
          _lastLoadedConversationId == conversationId &&
          _loadedMessageIds.isNotEmpty &&
          messages.isNotEmpty) {
        print('⏭️ Conversation $conversationId already loaded, skipping');
        return;
      }

      _conversationId = conversationId;
      _lastLoadedConversationId = conversationId;

      // Preserve any optimistic messages (temp messages that haven't been confirmed)
      final optimisticMessages = messages
          .where((m) => m.id.startsWith('temp_'))
          .toList();

      print('🔄 Loading conversation from API: $conversationId');
      print('💾 Preserving ${optimisticMessages.length} optimistic messages');

      // Fetch conversation from API
      final conversationResponse = await messageServiceRest
          .getSingleConversation(conversationId);

      // Clear and add API messages only once
      messages.clear();
      final apiMessages = _dedupeConversationMessages(
        conversationResponse.messages,
      );
      messages.addAll(apiMessages);

      // Store loaded message IDs to prevent duplicates from socket
      final loadedMessageIds = <String>{};
      for (final msg in apiMessages) {
        loadedMessageIds.add(msg.id);
      }
      _loadedMessageIds = loadedMessageIds;

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
        '✅ Loaded ${apiMessages.length} messages from API (deduped) + ${optimisticMessages.length} optimistic',
      );

      // Re-apply any cached service-request details (backend omits these from messages)
      _patchMessagesWithCache();

      // Reset flag after API load is complete
      // API load complete

      // IMPORTANT: Do NOT call _socket.loadConversation() because:
      // The server would send back ALL messages including those already loaded from API
      // This causes duplicates. Instead, we only listen for NEW messages via socket.
    } catch (e) {
      print('❌ Error loading conversation from API: $e');
      // Fallback to socket-only loading
      _socket.loadConversation(conversationId: conversationId);
    }
  }

  /// Initialize new conversation with a recipient
  void initNewConversation({
    required String recipientId,
    ChatParticipant? recipientParticipant,
  }) {
    _conversationId = null; // No existing conversation
    _recipientId = recipientId;
    _recipientParticipant = recipientParticipant;
    messages.clear();
    _loadedMessageIds.clear();
    _lastLoadedConversationId = null;
  }

  /// Current recipient ID for new conversations
  String? _recipientId;

  /// Recipient info for new conversations (used for local chat list preview)
  ChatParticipant? _recipientParticipant;

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

          // Only process if this is the currently active conversation
          if (conversationId != _conversationId) {
            print(
              '📭 Socket conversation data for different conversation: $conversationId vs $_conversationId, ignoring',
            );
            return;
          }

          // Skip if we have loaded messages from API (they should be in _loadedMessageIds)
          // This prevents duplicate full conversation syncs from socket
          if (_loadedMessageIds.isNotEmpty) {
            print(
              '⏭️ Ignoring full conversation sync from socket - already loaded from API',
            );
            return;
          }

          if (messagesList != null) {
            final conversationMessages = messagesList
                .map(
                  (msgData) =>
                      ChatMessage.fromJson(msgData as Map<String, dynamic>),
                )
                .toList();

            // Only add new messages that don't already exist
            int addedCount = 0;
            for (final newMsg in conversationMessages) {
              final exists = messages.any((m) => m.id == newMsg.id);
              if (!exists) {
                messages.add(newMsg);
                addedCount++;
              }
            }

            print(
              '✅ Synced ${conversationMessages.length} messages (added $addedCount new) for conversation $conversationId',
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
        // Check if already loaded from API
        if (_loadedMessageIds.contains(message.id)) {
          print('🔄 Message already loaded from API, skipping: ${message.id}');
          return;
        }

        // Check if message already exists (by ID or near-duplicate signature)
        final existingIndex = messages.indexWhere(
          (m) => m.id == message.id || _isNearDuplicate(m, message),
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
    String? serviceRequestId,
    List<String>? files,
  }) async {
    print('🔥 [MESSAGES_CONTROLLER] sendMessage called');
    print('🔥 [MESSAGES_CONTROLLER] recipientId: $recipientId');
    print(
      '🔥 [MESSAGES_CONTROLLER] recipientId type: ${recipientId.runtimeType}',
    );
    print('🔥 [MESSAGES_CONTROLLER] content: $content');
    print('🔥 [MESSAGES_CONTROLLER] serviceId: $serviceId');
    print('🔥 [MESSAGES_CONTROLLER] serviceRequestId: $serviceRequestId');

    if (content.trim().isEmpty &&
        (files == null || files.isEmpty) &&
        serviceId == null) {
      print(
        '❌ [MESSAGES_CONTROLLER] Content, files, and serviceId are all empty, returning',
      );
      return;
    }

    // Ensure user ID is set
    if (_myUserId == null || _myUserId!.isEmpty) {
      print('❌ Cannot send message: User ID not available');
      print('🔥 [MESSAGES_CONTROLLER] _myUserId: $_myUserId');
      return;
    }

    // Validate and sanitize recipientId
    String targetRecipientId = recipientId.trim();
    if (targetRecipientId.isEmpty) {
      targetRecipientId = _recipientId ?? '';
    }

    print(
      '🔥 [MESSAGES_CONTROLLER] Sanitized targetRecipientId: "$targetRecipientId"',
    );
    print(
      '🔥 [MESSAGES_CONTROLLER] Sanitized targetRecipientId length: ${targetRecipientId.length}',
    );

    if (targetRecipientId.isEmpty) {
      print("❌ Error: No valid recipient ID available");
      print(
        '🔥 [MESSAGES_CONTROLLER] targetRecipientId after sanitization: "$targetRecipientId"',
      );
      return;
    }

    print(
      '🔥 [MESSAGES_CONTROLLER] All checks passed, proceeding with message',
    );
    print('🔥 [MESSAGES_CONTROLLER] _myUserId: $_myUserId');
    print('🔥 [MESSAGES_CONTROLLER] targetRecipientId: $targetRecipientId');

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
      print('🔥 [MESSAGES_CONTROLLER] Calling messageServiceRest.sendMessage');
      print(
        '🔥 [MESSAGES_CONTROLLER] API call params - recipientId: $targetRecipientId, serviceId: $serviceId',
      );
      final sentMessage = await messageServiceRest.sendMessage(
        recipientId: targetRecipientId,
        content: content.trim(),
        serviceId: serviceId,
        serviceRequestId: serviceRequestId,
        files: files,
      );
      print('🔥 [MESSAGES_CONTROLLER] API call successful');
      print(
        '🔥 [MESSAGES_CONTROLLER] Sent message serviceId: ${sentMessage.serviceId}',
      );
      print(
        '🔥 [MESSAGES_CONTROLLER] Sent message service: ${sentMessage.service}',
      );

      // Replace optimistic message with real message from API
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = sentMessage;
        print('✅ Replaced optimistic message with API response');
      }

      // If this was a brand-new conversation, update our conversationId and
      // reconcile the chat list stub (which used an empty chatId).
      if ((_conversationId == null || _conversationId!.isEmpty) &&
          sentMessage.conversationId.isNotEmpty) {
        _conversationId = sentMessage.conversationId;
      }
      _updateChatListWithMessage(sentMessage);

      // If this message is a service request, the send-message API sometimes
      // returns `serviceId` but not the full `service` object. The UI service
      // card requires `service != null`, so force-refresh the conversation once.
      if (serviceId != null &&
          serviceId.trim().isNotEmpty &&
          sentMessage.serviceId != null &&
          sentMessage.service == null &&
          sentMessage.conversationId.isNotEmpty) {
        await initConversationFromAPI(
          conversationId: sentMessage.conversationId,
          force: true,
        );
      }

      // IMPORTANT:
      // Do NOT also send via socket here. In many backends the socket event also
      // persists the message, so sending via REST + socket creates duplicates
      // that appear after app reopen/hot-reload.
      // We rely on the backend to broadcast the new message to other clients.

      print('✅ Message sent successfully');
    } catch (e, stackTrace) {
      print('❌ Error sending message via API: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error stackTrace: $stackTrace');
      print('❌ Full error: $e');

      // Try to extract more details from the exception
      if (e is Exception) {
        print('❌ Exception message: ${e.toString()}');
      }

      // Keep optimistic message but mark it as failed/pending
      // You could add a status field to ChatMessage to show retry option

      // Try socket-only as fallback
      print('🔥 [MESSAGES_CONTROLLER] Attempting socket fallback...');
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

      final otherUserId = message.senderId == _myUserId
          ? (_recipientParticipant?.id ?? _recipientId)
          : message.senderId;

      int idx = -1;
      if (message.conversationId.isNotEmpty) {
        idx = allChats.indexWhere((c) => c.chatId == message.conversationId);
      }
      // If we previously created a local stub chat with empty chatId, try to
      // find it by participant id and update it with the real conversationId.
      if (idx == -1 &&
          message.conversationId.isNotEmpty &&
          otherUserId != null) {
        idx = allChats.indexWhere(
          (c) =>
              (c.chatId == null || c.chatId!.isEmpty) &&
              c.participant?.id == otherUserId,
        );
      }
      if (idx != -1) {
        final existing = allChats[idx];
        final updated = ChatItem(
          type: existing.type,
          chatId: message.conversationId.isNotEmpty
              ? message.conversationId
              : existing.chatId,
          participant: existing.participant,
          lastMessage: lastMsg,
          updatedAt: lastMsg.createdAt,
        );
        // move to top
        allChats.removeAt(idx);
        allChats.insert(0, updated);
      } else {
        // In the chat list, participant should be the OTHER person.
        final ChatParticipant participant;
        if (message.senderId == _myUserId) {
          participant =
              _recipientParticipant ??
              ChatParticipant(
                id: _recipientId,
                profilePhoto: null,
                fullName: null,
              );
        } else {
          participant = ChatParticipant(
            id: message.senderId,
            profilePhoto: message.sender.profilePhoto,
            fullName: message.sender.fullName,
          );
        }
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
