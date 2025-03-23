import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:padshala/Admin/local_notification.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/login/auth/auth_bloc.dart';
import 'package:padshala/screens/splash_screen.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}
// Initialize local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void checkFirestoreData() async {
  var firestore = FirebaseFirestore.instance;
  var snapshot = await firestore.collection("orders").get();

  if (snapshot.docs.isEmpty) {
    print("No documents found in 'orders' collection.");
  } else {
    for (var doc in snapshot.docs) {
      print("Document ID: ${doc.id} - Data: ${doc.data()}");
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Firebase.initializeApp();

  checkFirestoreData();

  
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }

  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground Message Received: ${message.notification?.title}");

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
       
        BlocProvider<CartBloc>(create: (context) => CartBloc()..add(LoadCartEvent()),
        ),
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