import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  void init() async {
    // 🔑 Request notification permissions
    await _messaging.requestPermission();

    // 🔁 Get FCM token
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

    // 🔔 Foreground notification handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          message.notification!.title ?? "No Title",
          message.notification!.body ?? "No Body",
        );
      }
    });

    // 📲 Handle tap when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Notification tapped: ${message.data}");
    });

    // 🛠 Local notification setup
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("🔔 Notification clicked with payload: ${response.payload}");
        // You can add navigation or logic here
      },
    );
  }


  void _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'campus_channel', // channel ID
      'Campus Notifications', // channel name
      channelDescription: 'Notifications for Campus App',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0, // notification ID
      title,
      body,
      notifDetails,
    );
  }
}
