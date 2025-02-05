
import 'package:firebase_auth/firebase_auth.dart'show FirebaseAuth, GoogleAuthProvider, User, kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _user = _auth.currentUser;
  }

  Future<void> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: "186899771699-7600jjuic2c8kosjor9eumb801l6kpkt.apps.googleusercontent.com", // Replace with your actual Web Client ID
    
  );
  GoogleSignInAccount? googleUser;

    if (kIsWeb) {
      // Use signInSilently() for web
      googleUser = await googleSignIn.signInSilently();
    } else {
      // Use regular signIn() for mobile
      googleUser = await googleSignIn.signIn();
    }

  if (googleUser == null) return; // User canceled sign-in

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    _user = _auth.currentUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}