import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padshala/screens/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:padshala/login/auth/auth_bloc.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
 
   if (message.notification != null) {
    showNotification(message.notification!); 
  }
}

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
  try{
  final fcmToken = await FirebaseMessaging.instance.getToken();
  final user = FirebaseAuth.instance.currentUser;
  debugPrint("🔥 Current User phonenumber: ${user?.phoneNumber}");

  if (user != null && fcmToken != null) {
    await FirebaseFirestore.instance
        .collection("admin_tokens")
        .doc(user.phoneNumber) 
        .set({
          "token": fcmToken,
        });
    print("FCM token saved for admin: ${user.phoneNumber}");
  } else {
    print("User is null or token not found.");
  }
} catch (e) {
    print("❌ Error saving FCM token: $e");
  }
}
Future<void> maybeSaveAdminFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('admins')
      .doc(user.phoneNumber)
      .get();

  if (doc.exists && doc.data()?['isAdmin'] == true) {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance
          .collection("admin_tokens")
          .doc(user.phoneNumber)
          .set({"token": fcmToken});
      print("✅ FCM token saved for admin: ${user.phoneNumber}");
    }
  } else {
    print("🔒 User is not admin; token not saved.");
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
  await dotenv.load(); 


   final connectivityResult = await Connectivity().checkConnectivity();
  final hasInternet = connectivityResult != ConnectivityResult.none;

  if (!hasInternet) {
    runApp(NoInternetScreen());
    return;
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity, 
);

  await checkFirestoreData();

  
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('Notification Permission: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    await maybeSaveAdminFcmToken();


    // 🔄 Auto-update token if it refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("admin_tokens")
            .doc(user.phoneNumber)
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
        BlocProvider<FavoriteBloc>(create: (context) => FavoriteBloc()),
        
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
class NoInternetScreen extends StatefulWidget {
  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }
Future<void> _checkConnectivity() async {
  _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
   
    if (results.isNotEmpty) {
      _updateConnectionStatus(results.first); 
    }
  });

  List<ConnectivityResult> connectivityResults = await _connectivity.checkConnectivity();
  if (connectivityResults.isNotEmpty) {
    _updateConnectionStatus(connectivityResults.first);
  }
}

 void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connectivity Example")),
      body: Center(
        child: _isOnline
            ? Text("You are connected to the internet!", style: TextStyle(fontSize: 20))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.signal_wifi_off, size: 50, color: Colors.red),
                  SizedBox(height: 20),
                  Text("No internet connection", style: TextStyle(fontSize: 20, color: Colors.red)),
                ],
              ),
      ),
    );
  }
}