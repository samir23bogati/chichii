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
  Future<void> signInWithGoogle(BuildContext context) async {
    print("Google Sign-In button clicked!");
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? null
            : "581466934152-r15f8jdlio8g53818b8bqkqnhqru6cgm.apps.googleusercontent.com", // Your Web Client ID for mobile
        signInOption: SignInOption.standard,
      );
      GoogleSignInAccount? googleUser;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(googleProvider);
      } else {
        googleUser = await googleSignIn.signIn();
        if (googleUser == null) return; // User canceled sign-in

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }

      _user = _auth.currentUser;
      notifyListeners();

     

    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }

  // Phone Number Authentication
  Future<String> signInWithPhoneNumber(BuildContext context, String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _user = _auth.currentUser;
          notifyListeners();

          
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone number verification failed: ${e.message}')),
          );
          throw Exception('Phone number verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          this.verificationId = verificationId;
          String? smsCode = await _getSmsCodeFromUser(context);
          if (smsCode != null) {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );
            await _auth.signInWithCredential(credential);
            _user = _auth.currentUser;
            notifyListeners();

            } else {
            throw Exception("SMS code not provided");
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return "Verification in progress";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      throw Exception("An error occurred during phone number sign-in: $e");
    }
  }

  // OTP Verification
  Future<bool> verifyOtp(BuildContext context, String otp, String verificationId) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      _user = _auth.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed: $e')),
      );
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }

  // Helper function to get SMS code from the user
  Future<String> _getSmsCodeFromUser(BuildContext context) async {
    TextEditingController smsController = TextEditingController();
    String smsCode = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter the SMS Code'),
          content: TextField(
            controller: smsController,
            decoration: InputDecoration(hintText: 'SMS Code'),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                smsCode = smsController.text.trim();
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
    if (smsCode.isEmpty) {
      throw Exception("SMS code is required");
    }
    return smsCode;
  }
}
