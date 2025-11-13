import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _loginChannel =
      AndroidNotificationChannel(
    'login_channel',
    'Login Notifications',
    description: 'Notifications presented after successful login.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    await _requestNotificationPermissions();
    await _initializeLocalNotifications();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleForegroundMessage);

    final token = await _messaging.getToken();
    if (kDebugMode) {
      debugPrint('FCM token: $token');
    }
  }

  Future<void> showLoginSuccessNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _loginChannelId,
      _loginChannelName,
      channelDescription: _loginChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      _loginNotificationId,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> _requestNotificationPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('User denied notification permissions');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _localNotificationsPlugin.initialize(initializationSettings);

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_loginChannel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final android = notification.android;
    if (android != null) {
      showLoginSuccessNotification(
        title: notification.title ?? 'New notification',
        body: notification.body ?? '',
      );
    }
  }

  static const int _loginNotificationId = 1001;
  static const String _loginChannelId = 'login_channel';
  static const String _loginChannelName = 'Login Notifications';
  static const String _loginChannelDescription =
      'Notifications that confirm a successful login.';
}


