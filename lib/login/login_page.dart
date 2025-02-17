import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:padshala/login/auth_provider.dart';
import 'package:padshala/login/map/address_selection_page.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // Import pin_code_fields for OTP input

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
  final TextEditingController _otpController = TextEditingController(); // OTP controller
  String? _verificationId;
  bool isOtpSent = false; // State to toggle between phone input and OTP verification
  bool isLoading = false;

  // Show phone number input dialog
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final phoneNumber = _phoneController.text.trim();
            if (phoneNumber.isNotEmpty && phoneNumber.length >= 10) {
              setState(() => isLoading = true);
              try {
                final verificationId = await authProvider.signInWithPhoneNumber(context, phoneNumber);
                setState(() {
                  _verificationId = verificationId;  // Store verificationId
                  isOtpSent = true;
                });
                Navigator.pop(context);
              } catch (e) {
                setState(() => isLoading = false);
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

  // Function to verify OTP
 void _verifyOtp(AuthProvider authProvider) async {
  final otp = _otpController.text.trim();
  if (otp.isNotEmpty && _verificationId != null) {
    setState(() => isLoading = true);
     try {
        final success = await authProvider.verifyOtp(context, otp, _verificationId!);
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40),
              color: Color.fromRGBO(55, 39, 6, 1),
              child: Column(
                children: [
                  Image.asset('assets/images/chichiisplash.png', height: 60),
                  SizedBox(height: 10),
                  Text(
                    "Login To Unlock Awesome",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "New Features",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Finger Linking Good",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "Great Deals & Offers",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "Easy Ordering",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            isOtpSent ? _buildOtpInput(context, authProvider) : _buildPhoneInput(context, authProvider),
            SizedBox(height: 20),
            Text("Login With Social Media Accounts"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              //  _socialButton(FontAwesomeIcons.facebook, "Facebook"),
                SizedBox(width: 10),
               _socialButton(FontAwesomeIcons.google, "Google", () async {
                  await authProvider.signInWithGoogle(context); // Call Google sign-in function
               }),
              ],
            ),
            // SizedBox(height: 20),
            // TextButton(
            //   onPressed: () {},
            //   child: Text("Skip Login & Continue"),
            // ),
          ],
        ),
      ),
    );
  }

  // Build phone number input UI
  Widget _buildPhoneInput(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            children: [
              Image.asset('assets/images/nepal_flag.png', height: 30),
              const SizedBox(width: 10),
              const Text("+977"),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Mobile Number",
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(55, 39, 6, 1),
          ),
          onPressed: () => _showPhoneNumberDialog(context, authProvider),
          child: const Text("OTP via SMS",
          style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Build OTP input UI
  Widget _buildOtpInput(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        const Text("Verify Your OTP sent via SMS"),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _otpController,
            keyboardType: TextInputType.number,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 50,
              fieldWidth: 40,
              activeFillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(55, 39, 6, 1),
          ),
          onPressed: () => _verifyOtp(authProvider),
          child: const Text("Verify OTP",
          style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Build social media login buttons
  Widget _socialButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap:onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: FaIcon(icon, size: 30),
      ),
    );
  }
}
