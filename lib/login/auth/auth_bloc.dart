import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? verificationId;
  Timer? _timer;

  AuthBloc() : super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<PhoneAuthRequested>(_onPhoneAuthRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<OtpSent>(_onOtpSent);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<CountdownTicked>(_onCountdownTicked);
  }

  Future<void> saveAdminFCMToken() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
 // Fetch user role from Firestore
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.phoneNumber).get();

  if (userDoc.exists && userDoc['role'] == 'admin') {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('admin_tokens').doc(user.phoneNumber).set({
        'token': token,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}

   void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async{
    final user =await _getCurrentUser();
    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<User?> _getCurrentUser() async {
  final user = _firebaseAuth.currentUser;
  return user;
}


void startCountdown(String phoneNumber, {int duration = 190}) { 
  _timer?.cancel();
  int remaining = duration;
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (remaining > 0) {
      remaining--;
      add(CountdownTicked(phoneNumber: phoneNumber, remainingTime: remaining));
    } else {
      timer.cancel();
      add(AuthFailure(message: "OTP expired! Please request a new one."));
    }
  });
}


 void _onCountdownTicked(CountdownTicked event, Emitter<AuthState> emit) {
    emit(OtpSentState(phoneNumber: event.phoneNumber, remainingTime: event.remainingTime));
  }
  
  // ✅ Google Sign-In Handling
  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(GoogleAuthLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthError(message: 'Google sign-in aborted'));
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);

        // Check if the user exists in Firestore and verify role
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();


       if (userDoc.exists) {
        // User exists, check if they are an admin
        final data = userDoc.data() as Map<String, dynamic>;
        if (data['role'] == 'admin') {
          await saveAdminFCMToken();  // Save FCM token for admins
        }
      } else {
        // If user does not exist, store their role as admin
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'role': 'admin',  // Set role as admin
          'email': userCredential.user!.email,
        });
        await saveAdminFCMToken(); // Save FCM token for new admin
      }

      emit(Authenticated(user: userCredential.user!));
    } else {
      emit(AuthError(message: 'Google sign-in failed'));
    }
  } catch (e) {
    emit(AuthError(message: e.toString()));
  }
  }


  // ✅ Phone Authentication Handling
  void _onPhoneAuthRequested( PhoneAuthRequested event, Emitter<AuthState> emit) async {
    emit(PhoneAuthLoading());
    try {
      await _sendPhoneNumber(event.phoneNumber);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ✅ OTP Verification Handling
  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(PhoneAuthLoading());
    try {
      final user = await _verifyOtp(event.otp);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
         emit(OtpVerified(user: user));
    } else {
      emit(AuthError(message: 'OTP verification failed'));
    }
  } catch (e) {
    emit(AuthError(message: 'Error verifying OTP: ${e.toString()}'));
  }
}

  // ✅ OTP Sent Handling
  void _onOtpSent(OtpSent event, Emitter<AuthState> emit) {
    emit(OtpSentState(phoneNumber: event.phoneNumber, remainingTime: event.remainingTime));
  }
   void _onResendOtpRequested(ResendOtpRequested event, Emitter<AuthState> emit) async {
    emit(PhoneAuthLoading());
     _timer?.cancel();
    try {
      await _sendPhoneNumber(event.phoneNumber);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }


 // ✅ Send OTP Function
Future<void> _sendPhoneNumber(String phoneNumber) async {

  String sanitizedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

  if (sanitizedPhoneNumber.isNotEmpty && sanitizedPhoneNumber.length >= 13) {
    final formattedPhoneNumber = sanitizedPhoneNumber; 

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
         timeout: const Duration(seconds: 110),
        verificationCompleted: (PhoneAuthCredential credential) async {
           final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
            // If auto-verification works, proceed directly to OTP verification
            add(VerifyOtpRequested(otp: 'AUTO',));  // Trigger OTP verification with the auto-filled OTP
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(message: 'Phone number verification failed: ${e.message}'));
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          
          startCountdown(phoneNumber); 
          add(OtpSent(phoneNumber: phoneNumber, remainingTime: 110)); 
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        emit(AuthError(message: 'Error sending OTP: ${e.message}'));
      } else {
        emit(AuthError(message: 'An unexpected error occurred.'));
      }
    }
  } else {
    emit(AuthError(message: 'Please enter a valid phone number with the country code'));
  }
}


Future<User?> _verifyOtp(String otp) async {
   if (verificationId == null) {
    emit(AuthError(message: "Verification ID is missing. Try again."));
    return null;
  }
  try {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otp,
    );
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  } catch (e) {
     emit(AuthError(message: "Invalid OTP. Please try again."));
    return null;
  }
}
 @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
