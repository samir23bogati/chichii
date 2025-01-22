import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
  return Container(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Image.asset(
          'assets/images/chichifooter.jpg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}