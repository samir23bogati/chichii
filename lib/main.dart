import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/homepage.dart';
import 'package:padshala/model/cart_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
     providers: [
        // Provide CartBloc to the widget tree
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(), // Instantiating CartBloc
        ),
        // Provide CartProvider (for ChangeNotifier) to the widget tree
        ChangeNotifierProvider<CartProvider>(
          create: (context) => CartProvider(),
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
