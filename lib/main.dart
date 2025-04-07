import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/common/favourites/fav_bloc.dart';
import 'package:padshala/login/auth/auth_bloc.dart';
import 'package:padshala/screens/splash_screen.dart';
// Initialize local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
 
   if (message.notification != null) {
    showNotification(message.notification!); 
  }
}
// Function to show notifications
Future<void> showNotification(RemoteNotification notification) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    notification.title,
    notification.body,
    notificationDetails,
  );
}
Future<void> saveFcmTokenToFirestore() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  final user = FirebaseAuth.instance.currentUser;
  debugPrint("🔥 Current User UID: ${user?.uid}");

  if (user != null && fcmToken != null) {
    await FirebaseFirestore.instance
        .collection("admin_tokens")
        .doc(user.uid) // or user.phoneNumber
        .set({
          "token": fcmToken,
        });
    print("FCM token saved for admin: ${user.uid}");
  } else {
    print("User is null or token not found.");
  }
}

Future <void> checkFirestoreData() async {
  var firestore = FirebaseFirestore.instance;
  try {
    var snapshot = await firestore.collection("orders").get();

    if (snapshot.size == 0) {
      print("No documents found in 'orders' collection.");
    } else {
      snapshot.docs.forEach((doc) {
        print("Document ID: ${doc.id} - Data: ${doc.data()}");
      });
    }
  } catch (e) {
    print("Error accessing Firestore: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await dotenv.load();
  await Firebase.initializeApp();

  await checkFirestoreData();

  
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    await saveFcmTokenToFirestore();

    // 🔄 Auto-update token if it refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      debugPrint("🔥 Current User UID: ${user?.uid}");
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("admin_tokens")
            .doc(user.uid)
            .set({"token": newToken});
        print("🔄 FCM token refreshed and updated in Firestore.");
      }
    });
  } else {
    print('❌ User declined or has not accepted notification permission');
  }

  // 🔊 Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📲 Foreground Message Received: ${message.notification?.title}");

    if (message.notification != null) {
      showNotification(message.notification!);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>( create: (context) => AuthBloc()),  
        BlocProvider<CartBloc>(create: (context) => CartBloc()..add(LoadCartEvent())),
        BlocProvider<FavoritesBloc>(create: (context) => FavoritesBloc()),
        
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChiChii',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.amber,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
