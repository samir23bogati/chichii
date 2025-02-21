import 'package:flutter/material.dart';
import 'package:padshala/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 double _opacity = 0.0;
  double _scale = 0.5;

@override
void initState() {
  super.initState();

  Future.delayed(const Duration(milliseconds: 400), () {
    setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

   Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(55, 39, 6, 1),
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: _opacity,
          child: AnimatedScale(
            duration: const Duration(seconds: 2),
            scale: _scale,
            curve: Curves.easeInOut,
            child: Image.asset(
              'assets/images/chichiisplash.png',
              width: 189,
              height: 189,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}