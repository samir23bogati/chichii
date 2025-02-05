import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:padshala/login/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo
              Center(
            child: Image.asset('assets/images/logo.webp'),
          ),
             
              const Text(
                "Welcome to ChiChii_Online",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Google Sign-In Button
              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.signInWithGoogle();
                  if (authProvider.user != null) {
                    Navigator.pop(context, true);
                  }
                },
                icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                label: const Text("Login with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Phone Number Login Button
              ElevatedButton.icon(
                onPressed: () {
                  // Implement phone authentication
                },
                icon: const FaIcon(FontAwesomeIcons.phone, color: Colors.white),
                label: const Text("Login with Phone Number"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
