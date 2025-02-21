import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? verificationId; // Store the verificationId here
  User? _user;
  User? get user => _user;

  AuthProvider() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Google Sign-In
  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(googleProvider);
      } else {
        GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return false; // User canceled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }

      _user = _auth.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      _showSnackBar(context, 'Google Sign-In failed: ${e.toString()}');
      return false;
    }
  }

  // Phone Number Authentication
  Future<String?> signInWithPhoneNumber(BuildContext context, String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _user = _auth.currentUser;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showSnackBar(context, 'Phone verification failed: ${e.message}');
          print('Error: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          this.verificationId = verificationId;
          print('Verification ID: $verificationId'); // Log it here
          notifyListeners();
        },
        timeout: const Duration(seconds: 490),
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      _showSnackBar(context, 'Error: ${e.toString()}');
      return "Error occurred";
    }
  }

  // OTP Verification
  Future<bool> verifyOtp(BuildContext context, String otp) async {
    try {
      if (otp.isEmpty) {
        _showSnackBar(context, 'Please enter the OTP.');
        return false;
      }

      if (verificationId == null) {
        _showSnackBar(
            context, 'Verification ID is null, please request OTP again.');
        return false;
      }

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      _user = _auth.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      _showSnackBar(context, 'OTP verification failed: ${e.toString()}');
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Sign-out error: $e');
    }
  }
  // Show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
  }
}
