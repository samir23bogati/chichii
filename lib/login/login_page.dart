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
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _navigateToAddressSelectionPage();
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
    create: (context) => AuthBloc()..add(CheckAuthStatus()),  
    child: BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _navigateToAddressSelectionPage();  
        } else if (state is AuthError) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }else if (state is OtpSentState) {
            setState(() {
              isOtpSent = true;
            });
          }
        },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                isOtpSent ? _buildOtpInput() : _buildPhoneInput(),
                const SizedBox(height: 25),
                const Text("Login With Social Media Accounts"),
                 const SizedBox(height: 10),
                _buildGoogleSignInButton(),
              ],
            ),
          ),
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

  Widget _buildPhoneInput() {
    return Column(
      children: [
        _buildPhoneNumberField(),
        const SizedBox(height: 10),
        isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(55, 39, 6, 1)),
                onPressed: _sendPhoneNumber,
                child: const Text("OTP via SMS", style: TextStyle(color: Colors.white)),
              ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
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
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Mobile Number",
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  void _sendPhoneNumber() {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isNotEmpty && phoneNumber.length == 10) {
      final formattedPhoneNumber = '+977$phoneNumber';
       print('Sending OTP for $formattedPhoneNumber'); // Debugging line
      context.read<AuthBloc>().add(PhoneAuthRequested(formattedPhoneNumber));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
    }
  }

  Widget _buildOtpInput() {
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
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(5),
              fieldHeight: 50,
              fieldWidth: 40,
              activeFillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(55, 39, 6, 1)),
          onPressed: _verifyOtp,
          child: const Text("Verify OTP", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.isNotEmpty) {
      context.read<AuthBloc>().add(VerifyOtpRequested(otp));
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
              ? const CircularProgressIndicator() // Show loading indicator
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