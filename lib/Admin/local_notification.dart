import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =  FlutterLocalNotificationsPlugin();

void showNotification(RemoteNotification notification) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'channel_id', 'channel_name',
    importance: Importance.high,
    priority: Priority.high,
  );

  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    notification.title, 
    notification.body,
    platformChannelSpecifics,
  );
}
