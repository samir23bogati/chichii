import 'package:flutter/material.dart';
import 'package:padshala/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChiChii', 
      theme: ThemeData(
        useMaterial3: false, 
        primarySwatch: Colors.amber, 
      ),
      home: HomePage(), 
    );
  }
}

