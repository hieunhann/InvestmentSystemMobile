import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Yêu cầu quyền thông báo (iOS & Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
    } else {
      print('❌ User declined permission');
    }

    // 2. Local Notifications Setup (để hiện thông báo khi app đang mở)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _localNotificationsPlugin.initialize(initializationSettings);
    print('✅ Local Notifications initialized');

    // 3. Xử lý thông báo khi app đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Received message in foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 4.Token (để gửi test từ console)
    try {
      print('⏳ Getting FCM Token...');
      String? token = await _messaging.getToken();
      if (token != null) {
        print('🚀 FCM TOKEN: $token');
      } else {
        print('⚠️ FCM Token is null');
      }
    } catch (e) {
      print('❌ Error getting FCM Token: $e');
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    showQuickNotification(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
    );
  }

  static void showQuickNotification(String title, String body) {
    const AndroidNotificationDetails androidDetail = AndroidNotificationDetails(
      'main_channel',
      'Main Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails noticeDetail = NotificationDetails(android: androidDetail);

    _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      noticeDetail,
    );
  }
}
