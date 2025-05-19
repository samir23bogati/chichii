import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:padshala/login/auth/auth_bloc.dart';
import 'package:padshala/login/auth/auth_event.dart';
import 'package:padshala/login/auth/auth_state.dart';
import 'package:padshala/login/map/address_selection_page.dart';
import 'package:padshala/model/cart_item.dart';
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
  bool isOtpSent = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsLoggedIn();
  }
 @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  
 void _checkIfUserIsLoggedIn() {
  context.read<AuthBloc>().add(CheckAuthStatus());
}
  void _sendPhoneNumber() {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isNotEmpty && phoneNumber.length == 10) {
      final formattedPhoneNumber = '+977$phoneNumber';
     setState(() {
      isLoading = true;
    });
    context.read<AuthBloc>().add(PhoneAuthRequested(phoneNumber: formattedPhoneNumber));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
         print("Current State: $state");
        if (state is OtpSentState) {
      setState(() {
        isOtpSent = true;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP has been sent to your phone')),
      );
    } else if (state is OtpVerified || state is Authenticated) {
      setState(() => isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToAddressSelectionPage();
      });
    } else if (state is AuthError) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.message}')),
      );
    } else if (state is GoogleAuthLoading) {
      setState(() => isLoading = true);
    }
  },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
               BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is OtpSentState) {
      return _buildOtpInput();
    } else {
      return _buildPhoneInput();
    }
  },
),

                const SizedBox(height: 25),
               // const Text("Login With Social Media Accounts"),
                // const SizedBox(height: 10),
                // _buildGoogleSignInButton(),
              ],
            ),
          ),
        ),
      );
  }
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 10),
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
              Text("Finger Licking Good", style: TextStyle(color: Colors.white, fontSize: 13.2)),
              Text("Great Deals & Offers", style: TextStyle(color: Colors.white, fontSize: 13.2)),
              Text("Easy Ordering", style: TextStyle(color: Colors.white, fontSize: 13.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      children: [
        _buildPhoneNumberField(),
        const SizedBox(height: 10),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(55, 39, 6, 1)),
                onPressed: isLoading? null: _sendPhoneNumber,
               child: const Text("OTP via SMS", style: TextStyle(color: Colors.white)),

)
      ],
    );
  }

 Widget _buildPhoneNumberField() {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset('assets/images/nepal_flag.png', height: 36),
          const SizedBox(width: 12),
          const Text("+977", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Mobile Number",
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildOtpInput() {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Verify Your OTP sent via SMS",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 13),
          PinCodeTextField(
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
            onCompleted: (pin) {
              print("Completed: $pin");
            },
            onChanged: (value) {
              print(value);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(55, 39, 6, 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: isLoading ? null : _verifyOtp,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Verify OTP", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.isNotEmpty) {
      setState(() {
      isLoading = true;
    });
      context.read<AuthBloc>().add(VerifyOtpRequested(otp: otp));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
    }
  }

 Widget _buildGoogleSignInButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
         icon: state is GoogleAuthLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const FaIcon(FontAwesomeIcons.google, color: Colors.red),
          label: const Text("Sign in with Google"),
          onPressed: state is GoogleAuthLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(GoogleSignInRequested());
                  
                },
        );
      },
    );
  }

  void _navigateToAddressSelectionPage() {
   print("Navigating to AddressSelectionPage");
   ScaffoldMessenger.of(context).clearSnackBars();
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
}