import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jconnect/firebase_options.dart';

const String _channelId = 'high_importance_channel';
const String _channelName = 'High Importance Notifications';
const String _channelDesc = 'This channel is used for important notifications.';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message received: ${message.messageId}');
  // Show local notification for data-only background messages
  if (message.notification == null && message.data.isNotEmpty) {
    await _showLocalNotification(
      title: message.data['title'] ?? 'New Message',
      body: message.data['body'] ?? '',
    );
  }
}

Future<void> _showLocalNotification({
  required String title,
  required String body,
}) async {
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

class FcmNotificationController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Reactive variable to store the token
  var fcmToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    // 1. Initialize flutter_local_notifications & create Android channel
    await _initLocalNotifications();

    // 2. Request Permission (Crucial for iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 3. Get the FCM token
      String? token = await messaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        debugPrint('FCM Token: ${fcmToken.value}');
      }

      // 4. Foreground messages — Firebase does NOT show a heads-up on Android
      //    when the app is open, so we display it manually.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message: ${message.messageId}');
        final notification = message.notification;
        if (notification != null) {
          _showLocalNotification(
            title: notification.title ?? '',
            body: notification.body ?? '',
          );
        }
      });

      // 5. Notification tapped while app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification tapped (background): ${message.messageId}');
      });

      // 6. App launched from a terminated-state notification tap
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App opened from terminated notification: ${initialMessage.messageId}');
      }
    }
  }

  Future<void> _initLocalNotifications() async {
    // Android: create the high-importance channel (matches AndroidManifest meta-data)
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

    // iOS: request display options
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