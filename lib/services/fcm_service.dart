// lib/services/fcm_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:resto2/firebase_options.dart';
import 'package:resto2/services/notification_display_service.dart'; // Add this import

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // --- THIS IS THE FIX ---
  final NotificationDisplayService _notificationDisplayService =
      NotificationDisplayService();
  // --- END OF FIX ---

  Stream<String?> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  Future<void> init() async {
    // --- THIS IS THE FIX ---
    // Initialize the local notifications service, which also creates the channel
    await _notificationDisplayService.init();
    // --- END OF FIX ---

    await _requestNotificationPermissions();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _setupForegroundMessageHandler();
  }

  Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint(
      'User granted notification permission: ${settings.authorizationStatus}',
    );
  }

  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification?.title}',
        );
        // --- THIS IS THE FIX ---
        // Use the new service to display the notification
        _notificationDisplayService.showNotification(message);
        // --- END OF FIX ---
      }
    });
  }

  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}
