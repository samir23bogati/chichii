import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:padshala/login/auth_provider.dart';
import 'package:padshala/login/map/address_selection_page.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  const LoginPage({
    required this.cartItems,
    required this.totalPrice,
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool isOtpSent = false;
  bool isLoading = false;

  void _navigateToAddressSelectionPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSelectionPage(
          cartItems: widget.cartItems,
          totalPrice: widget.totalPrice,
        ),
      ),
    );
  }

  Future<void> _sendPhoneNumber(AuthProvider authProvider) async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isNotEmpty && phoneNumber.length == 10) {
      final formattedPhoneNumber = '+977$phoneNumber';
      setState(() => isLoading = true);
      try {
        final verificationId = await authProvider.signInWithPhoneNumber(context, formattedPhoneNumber);
        setState(() {
          _verificationId = verificationId;
          isOtpSent = true;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        print("Error during OTP sending: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
    }
  }

 Future<void> _verifyOtp(AuthProvider authProvider) async { 
  final otp = _otpController.text.trim();
  print("Entered OTP: $otp");
  print("Verification ID: $_verificationId");
  if (otp.isNotEmpty && _verificationId != null) {
    setState(() => isLoading = true);
    try {
      final success = await authProvider.verifyOtp(context, otp);
      if (success) {
        _navigateToAddressSelectionPage(); 
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verification failed, please try again')),
        );
      }
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
            _buildHeader(),
            const SizedBox(height: 25),
            isOtpSent ? _buildOtpInput(authProvider) : _buildPhoneInput(authProvider),
            const SizedBox(height: 25),
            const Text("Login With Social Media Accounts"),
            _buildSocialLogin(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: const Color.fromRGBO(55, 39, 6, 1),
      child: Column(
        children: [
          Image.asset('assets/images/chichiisplash.png', height: 120),
          const SizedBox(height: 10),
          const Text(
            "Login To Unlock Awesome",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const Text(
            "New Features",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Finger Licking Good", style: TextStyle(color: Colors.white, fontSize: 13)),
              Text("Great Deals & Offers", style: TextStyle(color: Colors.white, fontSize: 13)),
              Text("Easy Ordering", style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(AuthProvider authProvider) {
    return Column(
      children: [
        _buildPhoneNumberField(),
        const SizedBox(height: 10),
        isLoading 
        ? CircularProgressIndicator() // Show loading spinner while waiting for OTP
        : ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(55, 39, 6, 1)),
          onPressed: () => _sendPhoneNumber(authProvider),
          child: const Text("OTP via SMS", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
      child: Row(
        children: [
          Image.asset('assets/images/nepal_flag.png', height: 36),
          const SizedBox(width: 12),
          const Text("+977"),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Mobile Number"),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput(AuthProvider authProvider) {
    return Column(
      children: [
        const Text("Verify Your OTP sent via SMS"),
        const SizedBox(height: 13),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            controller: _otpController,
            keyboardType: TextInputType.number,
            pinTheme: PinTheme(shape: PinCodeFieldShape.box, borderRadius: BorderRadius.circular(5), fieldHeight: 50, fieldWidth: 40, activeFillColor: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(55, 39, 6, 1)),
          onPressed: () => _verifyOtp(authProvider),
          child: const Text("Verify OTP", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

 Widget _buildSocialLogin(AuthProvider authProvider) {
  return _socialButton(FontAwesomeIcons.googlePlusG, "Google", () {
    _handleGoogleSignIn(authProvider);
  });
}

void _handleGoogleSignIn(AuthProvider authProvider) async {
  final isLoggedIn = await authProvider.signInWithGoogle(context);
  if (isLoggedIn) {
    _navigateToAddressSelectionPage();
}
}


  Widget _socialButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: FaIcon(icon, size: 33),
    );
  }
} 