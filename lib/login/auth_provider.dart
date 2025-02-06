
import 'package:firebase_auth/firebase_auth.dart'show FirebaseAuth, FirebaseAuthException, GoogleAuthProvider, PhoneAuthCredential, PhoneAuthProvider, User, kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _user = _auth.currentUser;
  }
// Helper method to show a dialog for SMS code input
Future<String> _getSmsCodeFromUser(BuildContext context) async {
  String smsCode = '';
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter the SMS Code'),
        content: TextField(
          onChanged: (value) {
            smsCode = value;
          },
          decoration: InputDecoration(hintText: 'SMS Code'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
  return smsCode;
}

   Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: "581466934152-r15f8jdlio8g53818b8bqkqnhqru6cgm.apps.googleusercontent.com", // Your Web Client ID
      );
  GoogleSignInAccount? googleUser;

    if (kIsWeb) {
      // Use signInSilently() for web
      googleUser = await googleSignIn.signInSilently();
    } else {
      // Use regular signIn() for mobile
      googleUser = await googleSignIn.signIn();
    }

  if (googleUser == null) {
     print('Google sign-in cancelled');
    return;
   } // User canceled sign-in

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
      _user = _auth.currentUser;
      notifyListeners();
      print('Google Sign-In successful: ${_user?.email}');
    } catch (e) {
      print('Error during Google Sign-In: $e');
    }
  }
  Future<void> signInWithPhoneNumber(BuildContext context, String phoneNumber) async {
    try{
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieve or auto-fill of code
        await _auth.signInWithCredential(credential);
        _user = _auth.currentUser;
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (context.mounted) { // Check if the widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone number verification failed: ${e.message}')),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Ask user for the verification code
        String smsCode = await _getSmsCodeFromUser(context);   // Show a dialog to get the code from the user

        // Create a PhoneAuthCredential with the code
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        // Sign in with the credential
        await _auth.signInWithCredential(credential);
        _user = _auth.currentUser;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  } catch (e) {
    if (context.mounted) { // Check if the widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
      print('Signed out successfully');
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }
}