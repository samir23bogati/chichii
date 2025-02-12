import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:padshala/login/auth_provider.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
   final List<CartItem> cartItems;
  final double totalPrice;

  LoginPage({
    required this.cartItems,
    required this.totalPrice,
  });



  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  void _showPhoneNumberDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Phone Number'),
        content: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Phone number'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async{
              final phoneNumber = _phoneController.text;
              if (phoneNumber.isNotEmpty && phoneNumber.length >= 10) {
                setState(() {
                  isLoading = true;
                });
                 try {
                  await authProvider.signInWithPhoneNumber(context, phoneNumber);
                  if (authProvider.user != null) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid phone number')),
                );
              }
            },
            child: const Text('Send Code'),
          ),
        ],
      ),
    );
  }

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
                  setState(() {
                    isLoading = true;
                  });
                  await authProvider.signInWithGoogle();
                  setState(() {
                    isLoading = false;
                  });
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
                onPressed: () => _showPhoneNumberDialog(context, authProvider),
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
