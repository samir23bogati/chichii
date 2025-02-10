import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/firebase_options.dart';
import 'package:padshala/homepage.dart';
import 'package:padshala/login/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 
   // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
    );
  }
    
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>( 
          create: (context) => AuthProvider(),
        ),
        BlocProvider<CartBloc>(
         create: (context) => CartBloc()..add(LoadCartEvent()),
        ),
      ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ChiChii',
          theme: ThemeData(
            useMaterial3: false,
            primarySwatch: Colors.amber,
          ),
          home: HomePage(),
      ),
     
    );
  }
}
