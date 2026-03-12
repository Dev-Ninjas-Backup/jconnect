import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/firebase_options.dart';

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
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  // For notification+data messages, the system tray handles display.
  // For data-only messages, we must show it ourselves.
  if (message.notification != null) return; // system handles this

  if (message.data.isNotEmpty) {
    try {
      await _ensureLocalNotificationsInitialized();
      await _showLocalNotification(
        title: message.data['title'] ?? message.data['heading'] ?? 'New Message',
        body: message.data['body'] ?? message.data['message'] ?? '',
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
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
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
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  _localNotificationsInitialized = true;
}

@pragma('vm:entry-point')
Future<void> _showLocalNotification({
  required String title,
  required String body,
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
  const NotificationDetails details =
      NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    details,
  );
}

// ─── CONTROLLER ───────────────────────────────────────────────────────
class FcmNotificationController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  var fcmToken = ''.obs;

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
      } else {
        _log('getFreshToken returned null');
      }
    } catch (e) {
      _log('getFreshToken ERROR: $e');
    }
    return fcmToken.value;
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

      final bearer =
          authToken.startsWith('Bearer ') ? authToken : 'Bearer $authToken';
      final response = await http.patch(
        Uri.parse(Endpoint.editProfile),
        headers: {
          'Authorization': bearer,
          'Content-Type': 'application/json',
        },
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

    // ── Step 4: Request permission (Android 13+ shows dialog) ──────────
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _log('Step 4 OK: permission = ${settings.authorizationStatus}');
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
        await syncTokenWithBackend(token);
      } else {
        _log('Step 5 WARN: getToken() returned null — retrying in 5s');
        await Future.delayed(const Duration(seconds: 5));
        token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          fcmToken.value = token;
          _log('Step 5 OK (retry): token = ${token.substring(0, 20)}...');
          await syncTokenWithBackend(token);
        } else {
          _log('Step 5 FAIL: getToken() still null after retry');
        }
      }
    } catch (e) {
      _log('Step 5 ERROR: getToken() threw: $e');
    }

    // ── Step 6: Foreground message listener ─────────────────────────────
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _log('FG message received: id=${message.messageId}');
        try {
          final notification = message.notification;
          if (notification != null) {
            // Has notification payload — show it
            _showLocalNotification(
              title: notification.title ?? '',
              body: notification.body ?? '',
            );
          } else if (message.data.isNotEmpty) {
            // Data-only payload — extract title/body from data
            _showLocalNotification(
              title: message.data['title'] ??
                  message.data['heading'] ??
                  'New notification',
              body: message.data['body'] ??
                  message.data['message'] ??
                  '',
            );
          }
        } catch (e) {
          _log('FG message display error: $e');
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
      });
    } catch (e) {
      _log('Step 7 WARN: onMessageOpenedApp failed: $e');
    }

    // ── Step 8: Terminated → launch listener ────────────────────────────
    try {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _log('App launched from notification: ${initialMessage.messageId}');
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
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }
}