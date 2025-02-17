import 'package:flutter/material.dart';
import 'package:padshala/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


@override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  HomePage()),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(55, 39, 6, 1), // RGBA color
      body: Center(
        child: Image.asset(
          'assets/images/chichiisplash.png',
          width: 189,
          height: 189,
          fit:BoxFit.cover
        ),
      ),
    );
  }
}