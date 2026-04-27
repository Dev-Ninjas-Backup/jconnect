// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:jconnect/features/home/notification/screen/notification_screen.dart';
import 'package:jconnect/features/messages/chat_details/screen/chat_details_screen.dart';
import 'package:jconnect/firebase_options.dart';
import 'package:jconnect/routes/approute.dart';

const String _channelId = 'high_importance_channel';
const String _channelName = 'High Importance Notifications';
const String _channelDesc = 'This channel is used for important notifications.';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ─── BACKGROUND HANDLER (top-level, isolated from main) ───────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  // For notification+data messages, the system tray handles display.
  // For data-only messages, we must show it ourselves.
  if (message.notification != null) return; // system handles this

  if (message.data.isNotEmpty) {
    try {
      await _ensureLocalNotificationsInitialized();
      await _showLocalNotification(
        title:
            message.data['title'] ?? message.data['heading'] ?? 'New Message',
        body: message.data['body'] ?? message.data['message'] ?? '',
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      // Silently fail — cannot show UI in background isolate
    }
  }
}

bool _localNotificationsInitialized = false;

@pragma('vm:entry-point')
Future<void> _ensureLocalNotificationsInitialized() async {
  if (_localNotificationsInitialized) return;
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDesc,
    importance: Importance.max,
    playSound: true,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
  _localNotificationsInitialized = true;
}

@pragma('vm:entry-point')
Future<void> _showLocalNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  if (title.isEmpty && body.isEmpty) return;
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDesc,
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
  );
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    details,
    payload: payload,
  );
}

// ─── CONTROLLER ───────────────────────────────────────────────────────
class FcmNotificationController extends GetxController {
  var openedFromNotification = false.obs;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  var fcmToken = ''.obs;
  String? _lastTapSignature;
  DateTime? _lastTapTime;

  /// Diagnostic for the user (visible via UI if needed)
  var diagnosticLog = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _setupFCM();
  }

  void _log(String msg) {
    // print() works both in debug AND release (logcat)
    print('[FCM] $msg');
    diagnosticLog.value += '$msg\n';
  }

  /// Gets a fresh token from FCM. Call this at login/signup time.
  Future<String> getFreshToken() async {
    try {
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        fcmToken.value = token;
        _log('getFreshToken OK: ${token.substring(0, 20)}...');
        printFcmToken();
      } else {
        _log('getFreshToken returned null');
      }
    } catch (e) {
      _log('getFreshToken ERROR: $e');
    }
    return fcmToken.value;
  }

  /// Prints the current FCM token to console
  void printFcmToken() {
    print('╔════════════════════════════════════╗');
    print('║         FCM TOKEN                  ║');
    print('╠════════════════════════════════════╣');
    print('║ ${fcmToken.value}');
    print('╚════════════════════════════════════╝');
  }

  /// Helper to convert AuthorizationStatus to readable text
  String _getAuthStatusText(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return 'AUTHORIZED ✅';
      case AuthorizationStatus.denied:
        return 'DENIED ❌';
      case AuthorizationStatus.notDetermined:
        return 'NOT_DETERMINED ⏳';
      case AuthorizationStatus.provisional:
        return 'PROVISIONAL ⚠️';
    }
  }

  /// Syncs FCM token with the backend. Call after login succeeds.
  Future<void> syncTokenWithBackend(String token) async {
    if (token.isEmpty) {
      _log('syncToken SKIP: empty token');
      return;
    }
    try {
      final prefHelper = Get.find<SharedPreferencesHelperController>();
      final authToken = await prefHelper.getAccessToken();
      if (authToken == null || authToken.isEmpty) {
        _log('syncToken SKIP: not logged in');
        return;
      }

      final bearer = authToken.startsWith('Bearer ')
          ? authToken
          : 'Bearer $authToken';
      final response = await http.patch(
        Uri.parse(Endpoint.editProfile),
        headers: {'Authorization': bearer, 'Content-Type': 'application/json'},
        body: jsonEncode({'fcmToken': token}),
      );
      _log('syncToken response: ${response.statusCode}');
    } catch (e) {
      _log('syncToken ERROR: $e');
    }
  }

  // ─── MAIN SETUP ──────────────────────────────────────────────────────
  Future<void> _setupFCM() async {
    _log('_setupFCM START');

    // ── Step 1: Local notifications (independent — failure here must not
    //    prevent token retrieval or listener setup) ──────────────────────
    try {
      await _initLocalNotifications();
      _log('Step 1 OK: local notifications initialized');
    } catch (e) {
      _log('Step 1 WARN: local notifications failed: $e');
    }

    // ── Step 2: Enable auto-init (ensures Firebase creates an Installation
    //    ID even if getToken() isn't called) ─────────────────────────────
    try {
      await messaging.setAutoInitEnabled(true);
      _log('Step 2 OK: auto-init enabled');
    } catch (e) {
      _log('Step 2 WARN: setAutoInitEnabled failed: $e');
    }

    // ── Step 3: Register onTokenRefresh BEFORE getToken() so we never
    //    miss a rotation ─────────────────────────────────────────────────
    try {
      messaging.onTokenRefresh.listen((newToken) async {
        fcmToken.value = newToken;
        _log('Token REFRESHED: ${newToken.substring(0, 20)}...');
        await syncTokenWithBackend(newToken);
      });
      _log('Step 3 OK: onTokenRefresh listener registered');
    } catch (e) {
      _log('Step 3 WARN: onTokenRefresh failed: $e');
    }

    // ── Step 4: Request permission (Android 13+ shows dialog, iOS too) ────
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false, // Explicit permission, not provisional for iOS
      );
      _log('Step 4 OK: permission = ${settings.authorizationStatus}');
      _log('   iOS AuthStatus: ${_getAuthStatusText(settings.authorizationStatus)}');
    } catch (e) {
      _log('Step 4 WARN: requestPermission failed: $e');
    }

    // ── Step 5: Get FCM token (with retry) ─────────────────────────────
    // This is THE critical step. If this fails, push won't work.
    try {
      String? token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        fcmToken.value = token;
        _log('Step 5 OK: token = ${token.substring(0, 20)}...');
        printFcmToken();
        await syncTokenWithBackend(token);
      } else {
        _log('Step 5 WARN: getToken() returned null — retrying in 5s');
        await Future.delayed(const Duration(seconds: 5));
        token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          fcmToken.value = token;
          _log('Step 5 OK (retry): token = ${token.substring(0, 20)}...');
          printFcmToken();
          await syncTokenWithBackend(token);
        } else {
          _log('Step 5 FAIL: getToken() still null after retry');
        }
      }
    } catch (e) {
      _log('Step 5 ERROR: getToken() threw: $e');
    }

    // ── Step 6: Foreground message listener ─────────────────────────────
    // NOTE: iOS automatically shows foreground notifications via
    // setForegroundNotificationPresentationOptions(). Android requires
    // manual display, so we show it here for Android only.
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _log('FG message received: id=${message.messageId}');
        if (message.notification != null) {
          _log('   Title: ${message.notification?.title}');
          _log('   Body: ${message.notification?.body}');
          
          // Android: Manually show foreground notification
          // (iOS handles it via setForegroundNotificationPresentationOptions)
          _showLocalNotification(
            title: message.notification?.title ?? 'New Message',
            body: message.notification?.body ?? '',
            payload: jsonEncode(message.data),
          );
        }
        if (message.data.isNotEmpty) {
          _log('   Data: ${message.data}');
        }
      });
      _log('Step 6 OK: foreground listener registered');
    } catch (e) {
      _log('Step 6 WARN: foreground listener failed: $e');
    }

    // ── Step 7: Background tap listener ─────────────────────────────────
    try {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _log('Notification tapped (background): ${message.messageId}');
        _handleNotificationTap(message);
      });
    } catch (e) {
      _log('Step 7 WARN: onMessageOpenedApp failed: $e');
    }

    // ── Step 8: Terminated → launch listener ────────────────────────────
    try {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _log('App launched from notification: ${initialMessage.messageId}');
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      _log('Step 8 WARN: getInitialMessage failed: $e');
    }

    _log('_setupFCM COMPLETE');
  }

  // ─── LOCAL NOTIFICATIONS INIT ─────────────────────────────────────────
  Future<void> _initLocalNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // iOS: Request notification permissions
    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS: Set presentation options for foreground notifications
    // This is CRITICAL for iOS — without this, foreground notifications won't show
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response.payload);
      },
    );
  }

  void _handleLocalNotificationTap(String? payload) {
    openedFromNotification.value = true;

    _log('🔔 Local notification tapped: payload=$payload');
    if (payload == null || payload.isEmpty) {
      _log('❌ Local notification tap: payload is null/empty');
      return;
    }
    try {
      final decoded = jsonDecode(payload);
      _log('✅ Local notification decoded: $decoded');
      if (decoded is Map<String, dynamic>) {
        _routeFromNotificationData(data: decoded);
      } else if (decoded is Map) {
        _routeFromNotificationData(data: Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      _log('❌ Local notification payload parse error: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    openedFromNotification.value = true;

    _log('🔔 FCM notification tapped: messageId=${message.messageId}');
    _log('📋 Notification data: ${message.data}');
    _log('📋 Notification title: ${message.notification?.title}');
    _log('📋 Notification body: ${message.notification?.body}');
    _routeFromNotificationData(
      data: Map<String, dynamic>.from(message.data),
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }

  void _routeFromNotificationData({
    required Map<String, dynamic> data,
    String? title,
    String? body,
  }) {
    _log('🚀 _routeFromNotificationData called');
    _log('   title=$title, body=$body');
    _log('   data=$data');

    final type = _resolveNotificationType(data, title: title, body: body);
    _log('✅ Resolved notification type: $type');

    final signature = '$type|$title|$body|${jsonEncode(data)}';
    final now = DateTime.now();

    if (_lastTapSignature == signature &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!).inSeconds < 2) {
      _log('⚠️ Duplicate tap detected within 2s, ignoring');
      return;
    }

    _lastTapSignature = signature;
    _lastTapTime = now;

    _log('⏳ Delaying 350ms before navigation...');
    Future.delayed(const Duration(milliseconds: 350), () async {
      _log('📲 Navigation delay complete, routing now...');

      if (type == 'service') {
        _log('➡️ Routing to notification screen (service)');
        // Use Get.to() to navigate on top of current screen without replacing stack
        Get.offAllNamed(AppRoute.navBarScreen);

        Future.delayed(const Duration(milliseconds: 100), () {
          Get.to(() => NotificationScreen());
        });

        return;
      }

      if (type == 'inquiry') {
        _log('➡️ Routing to notification screen (inquiry)');
        Get.offAllNamed(AppRoute.navBarScreen);

        Future.delayed(const Duration(milliseconds: 100), () {
          Get.to(() => NotificationScreen());
        });

        return;
      }

      if (type == 'message') {
        // Extract message content for checking
        final messageContent = data['message']?.toString().toLowerCase() ?? '';
        final bodyContent = body?.toLowerCase() ?? '';
        final titleContent = title?.toLowerCase().trim() ?? '';

        _log('   Message routing check:');
        _log('      title="$titleContent"');
        _log('      body="$bodyContent"');
        _log('      data[message]="$messageContent"');

        // Check if it's a service request message (should go to notification screen)
        final isServiceRequestMessage =
            titleContent.contains('new message') ||
            messageContent.contains('sent you a message') ||
            bodyContent.contains('sent you a message') ||
            messageContent.contains('buy') ||
            messageContent.contains('service') ||
            bodyContent.contains('buy') ||
            bodyContent.contains('service');

        _log('   isServiceRequestMessage=$isServiceRequestMessage');

        if (isServiceRequestMessage) {
          _log('➡️ Routing to notification screen (Service Request Message)');
          Get.offAllNamed(AppRoute.navBarScreen);

          Future.delayed(const Duration(milliseconds: 100), () {
            Get.to(() => NotificationScreen());
          });
        } else {
          // Regular chat messages go to chat details
          _log('➡️ Routing to message/chat details');
          await _openMessageDetails(data, title: title);
        }
        return;
      }
        Get.offAllNamed(AppRoute.navBarScreen);

        Future.delayed(const Duration(milliseconds: 100), () {
          Get.to(() => NotificationScreen());
        });

        return;
    });
  }

  String _resolveNotificationType(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    final rawType = _firstNonEmpty(data, const [
      'type',
      'event',
      'notificationType',
      'category',
      'action',
    ]);

    _log('   rawType=$rawType');
    _log('   data keys: ${data.keys.join(", ")}');

    final descriptor = [
      rawType,
      title,
      body,
      data['title']?.toString(),
      data['message']?.toString(),
    ].whereType<String>().join(' ').toLowerCase();

    _log('   descriptor=$descriptor');

    // ✅ Match service notifications
    if (descriptor.contains('service.create') ||
        (descriptor.contains('service') && descriptor.contains('create')) ||
        descriptor.startsWith('new service')) {
      _log('   ✅ Matched: service (by service.create pattern)');
      return 'service';
    }

    // ✅ Match service by ANNOUNCEMENT + serviceId (from local notification tap)
    if (rawType?.toLowerCase() == 'announcement' &&
        data.containsKey('serviceId')) {
      _log('   ✅ Matched: service (by ANNOUNCEMENT + serviceId)');
      return 'service';
    }

    // ✅ Match inquiry notifications BEFORE message (priority - inquiry can have message in its text)
    // Check for inquiry-specific fields in data AND descriptor patterns
    final conversationId = data['conversationId']?.toString() ?? '';
    final chatId = data['chatId']?.toString() ?? '';
    final hasInquiryPrefix =
        conversationId.startsWith('inquiry_') || chatId.startsWith('inquiry_');

    final hasInquiryField =
        data.containsKey('inquiryId') ||
        data.containsKey('inqui_id') ||
        data.containsKey('inquiryTitle') ||
        hasInquiryPrefix ||
        data.keys.join(',').toLowerCase().contains('inquiry');

    _log(
      '   Inquiry check: hasInquiryPrefix=$hasInquiryPrefix (conversationId="$conversationId")',
    );

    if (hasInquiryField ||
        rawType?.toLowerCase() == 'inquiry.create' ||
        descriptor.contains('inquiry.create') ||
        descriptor.contains('new inquiry received') ||
        descriptor.contains('inquiry') ||
        descriptor.contains('inquire')) {
      _log(
        '   ✅ Matched: inquiry (hasInquiryField=$hasInquiryField, hasInquiryPrefix=$hasInquiryPrefix)',
      );
      return 'inquiry';
    }

    // ✅ Match message/chat notifications (AFTER inquiry check to avoid false positives)
    if (descriptor.contains('message') ||
        descriptor.contains('chat') ||
        descriptor.contains('private-chat')) {
      _log('   ✅ Matched: message');
      return 'message';
    }

    _log('   ⚠️ No match found for type=$rawType');
    return '';
  }

  Future<void> _openMessageDetails(
    Map<String, dynamic> data, {
    String? title,
  }) async {
    _log('💬 _openMessageDetails called');

    final chatId = _firstNonEmpty(data, const [
      'chatId',
      'conversationId',
      'conversation_id',
      'privateChatId',
      'private_chat_id',
    ]);

    final recipientId = _firstNonEmpty(data, const [
      'recipientId',
      'recipient_id',
      'senderId',
      'sender_id',
      'userId',
      'user_id',
      'artistId',
      'artist_id',
    ]);

    var username = _firstNonEmpty(data, const [
      'senderUsername',
      'sender_name',
      'username',
      'full_name',
      'name',
    ]);

    var profilePhoto = _firstNonEmpty(data, const ['profilePhoto', 'avatar']);

    _log(
      '   Initial data: chatId=$chatId, recipientId=$recipientId, username=$username, photo=$profilePhoto',
    );

    // Try to get user info from existing chats in MessagesController
    if (recipientId != null && recipientId.isNotEmpty) {
      try {
        final messagesController = Get.find<MessagesController>();
        final existingChat = messagesController.allChats.firstWhereOrNull(
          (chat) => chat.participant?.id == recipientId,
        );

        if (existingChat != null) {
          _log('   Found existing chat! Using participant info from there');
          final existingParticipant = existingChat.participant;
          if (existingParticipant != null) {
            username ??=
                existingParticipant.username ?? existingParticipant.fullName;
            profilePhoto ??= existingParticipant.profilePhoto;
            _log(
              '   Updated from existing: username=$username, photo=$profilePhoto',
            );
          }
        }
      } catch (e) {
        _log('   ⚠️ Could not access MessagesController: $e');
      }
    }

    final participant = ChatParticipant(
      id: recipientId,
      username: username,
      fullName: username,
      profilePhoto: profilePhoto,
    );

    final chatItem = ChatItem(
      type: 'private',
      chatId: chatId,
      participant: participant,
    );

    _log('   ➡️ Calling Get.to(ChatDetailsScreen)');
    _log(
      '   Arguments: chatId=$chatId, recipientId=$recipientId, isNew=${(chatId == null || chatId.isEmpty)}, senderUsername=$username',
    );
    try {
      Get.offAllNamed(AppRoute.navBarScreen);

      Future.delayed(const Duration(milliseconds: 100), () {
        Get.to(
          () => ChatDetailsScreen(),
          arguments: {
            'chatItem': chatItem,
            'recipientId': recipientId ?? '',
            'isNewConversation': (chatId == null || chatId.isEmpty),
            'senderUsername': username ?? title ?? 'User',
          },
        );
      });

      // await Get.offAll(
      //   () => ChatDetailsScreen(),
      //   arguments: {
      //     'chatItem': chatItem,
      //     'recipientId': recipientId ?? '',
      //     'isNewConversation': (chatId == null || chatId.isEmpty),
      //     'senderUsername': username ?? title ?? 'User',
      //   },
      // //  transition: Transition.rightToLeft,
      // );
      _log('   ✅ Successfully navigated to ChatDetailsScreen');
    } catch (e) {
      _log('   ❌ Error navigating to chatDetailsScreen: $e');
    }
  }

  String? _firstNonEmpty(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        _log('      Found key "$key": $text');
        return text;
      }
    }

    final metaRaw = data['meta'] ?? data['metadata'];
    if (metaRaw is Map<String, dynamic>) {
      for (final key in keys) {
        final value = metaRaw[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty && text.toLowerCase() != 'null') {
          _log('      Found in meta, key "$key": $text');
          return text;
        }
      }
    }

    _log('      No matching keys found in [${keys.join(", ")}]');
    return null;
  }
}
