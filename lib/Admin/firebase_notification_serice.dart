import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize FCM
  Future<void> initNotifications() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("User denied notifications");
      return;
    }

    // Get the FCM Token for this device
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

    // Store token in Firestore (Admins should be added manually)
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('adminTokens')
          .doc('admin1') // Use unique IDs for multiple admins
          .set({"token": token});
    }

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("New notification: ${message.notification?.title}");
      _showNotification(message);
    });
  }

  // Show notification in the app
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails("channel_id", "channel_name",
            importance: Importance.high, priority: Priority.high);

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }
}
