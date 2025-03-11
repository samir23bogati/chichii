import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

   void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) {
    final user = _getCurrentUser();
    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
    }
  }

  User? _getCurrentUser() {
    return _firebaseAuth.currentUser; 
  }

 void startCountdown(String phoneNumber) {
  int duration = 120; // 120 seconds timeout
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (duration > 0) {
      duration--;
      add(CountdownTicked(phoneNumber: phoneNumber, remainingTime: duration));
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        emit(Authenticated(user: userCredential.user!));
      } else {
        emit(AuthError(message: 'Google sign-in failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ✅ Phone Authentication Handling
  Future<void> _onPhoneAuthRequested(
      PhoneAuthRequested event, Emitter<AuthState> emit) async {
    emit(PhoneAuthLoading());
    try {
      await _sendPhoneNumber(event.phoneNumber);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ✅ OTP Verification Handling
  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(PhoneAuthLoading());
    try {
      final user = await _verifyOtp(event.otp);
      if (user != null) {
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
    try {
      await _sendPhoneNumber(event.phoneNumber);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }


 // ✅ Send OTP Function
Future<void> _sendPhoneNumber(String phoneNumber) async {
  print("Phone number received for OTP: $phoneNumber");

  String sanitizedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  print("Sanitized phone number: $sanitizedPhoneNumber");

  if (sanitizedPhoneNumber.isNotEmpty && sanitizedPhoneNumber.length >= 13) {
    final formattedPhoneNumber = sanitizedPhoneNumber; // Assuming the phone number already has the country code
    print("Formatted phone number: $formattedPhoneNumber");

    try {
      print("Sending OTP to $formattedPhoneNumber");
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
         timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Phone authentication completed with credential: $credential");
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.code} - ${e.message}");
          emit(AuthError(message: 'Phone number verification failed: ${e.message}'));
        },
        codeSent: (String verificationId, int? resendToken) {
          print("OTP Sent Successfully. Verification ID: $verificationId");
          this.verificationId = verificationId;
          
          // Start countdown with the correct initial duration (e.g., 120 seconds)
          int initialDuration = 120;
          startCountdown(phoneNumber); 
          add(OtpSent(phoneNumber: phoneNumber, remainingTime: initialDuration)); // Pass the initial duration here
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Auto retrieval timeout. Verification ID: $verificationId");
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        print("Error sending OTP: ${e.code} - ${e.message}");
        emit(AuthError(message: 'Error sending OTP: ${e.message}'));
      } else {
        print("Error: $e");
        emit(AuthError(message: 'An unexpected error occurred.'));
      }
    }
  } else {
    print("Formatted phone number is invalid: $sanitizedPhoneNumber");
    emit(AuthError(message: 'Please enter a valid phone number with the country code'));
  }
}

Future<User?> _verifyOtp(String otp) async {
  try {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otp,
    );
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  } catch (e) {
    print("OTP verification failed: $e");
    return null;
  }
}
 @override
  Future<void> close() {
    _timer?.cancel(); // Cancel the timer when closing bloc
    return super.close();
  }
}