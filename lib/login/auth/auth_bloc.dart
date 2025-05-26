import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padshala/screens/integrity_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';



class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  Timer? _countdownTimer;

  AuthBloc() : super(AuthInitial()) {
   on<CheckAuthStatus>(_onCheckAuthStatus);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<PhoneAuthRequested>(_onPhoneAuthRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<CountdownTicked>(_onCountdownTicked);
     on<OtpSent>(_onOtpSent);
    on<AuthFailure>(_onAuthFailure);
  }

 Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(GoogleAuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(Unauthenticated());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      emit(Authenticated(user: userCredential.user!));
    } catch (e) {
      emit(AuthError(message: 'Google sign-in failed: $e'));
    }
  }

 Future<void> _onPhoneAuthRequested(
    PhoneAuthRequested event, Emitter<AuthState> emit) async {
  print("📞 Starting phone auth for: ${event.phoneNumber}");
  emit(PhoneAuthLoading());

  // ✅ 1. Get Play Integrity Token
  final token = await IntegrityHelper.getPlayIntegrityToken();

  if (token == null) {
    print("❌ Failed to get Play Integrity token");
    emit(AuthError(message: "Failed Play Integrity check."));
    return;
  }

  print("✅ Play Integrity Token received: $token");

  // ✅ 2. Proceed with phone verification only if token is valid
  try {
    await _auth.verifyPhoneNumber(
      phoneNumber: event.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("✅ Auto verification completed.");
        try {
          UserCredential userCredential = await _auth.signInWithCredential(credential);
          emit(Authenticated(user: userCredential.user!));
        } catch (e) {
          print("❌ Sign-in after auto-verification failed: $e");
          emit(AuthError(message: "Auto-verification failed: $e"));
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print("❌ Verification failed: ${e.message}");
        emit(AuthError(message: e.message ?? "Verification failed."));
      },
      codeSent: (String verificationId, int? resendToken) {
        print("📨 Code sent! VerificationId: $verificationId");
        _verificationId = verificationId;
        add(OtpSent(phoneNumber: event.phoneNumber, remainingTime: 60));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("⏰ Auto retrieval timeout.");
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  } catch (e) {
    print("🚨 Exception in verifyPhoneNumber: $e");
    emit(AuthError(message: 'Phone auth error: $e'));
  }
}


  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(PhoneAuthLoading());

     if (_verificationId == null) {
      emit(AuthError(message: 'Verification ID is null. Please request OTP again.'));
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: event.otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      emit(OtpVerified(user: userCredential.user!));
    } catch (e) {
      print("❌ OTP verification failed: $e");
      emit(AuthError(message: 'Invalid OTP: $e'));
    }
  }

  Future<void> _onResendOtpRequested(
      ResendOtpRequested event, Emitter<AuthState> emit) async {
    _countdownTimer?.cancel(); // 🔁 Cancel any ongoing countdown before resending
     print("🔄 Resending OTP to ${event.phoneNumber}");
    add(PhoneAuthRequested(phoneNumber: event.phoneNumber));
  }

  void _onCountdownTicked(
      CountdownTicked event, Emitter<AuthState> emit) {
    if (event.remainingTime > 0) {
      emit(OtpSentState(
          phoneNumber: event.phoneNumber,
          remainingTime: event.remainingTime));
    } else {
      _countdownTimer?.cancel();
    }
  }
  void _onOtpSent(OtpSent event, Emitter<AuthState> emit) {
    print("✅ OTP sent event handled.");
    emit(OtpSentState(
      phoneNumber: event.phoneNumber,
      remainingTime: event.remainingTime,
    ));
    _startCountdown(event.phoneNumber);
  }

  void _startCountdown(String phoneNumber) {
    int remainingTime = 60;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      remainingTime--;
      add(CountdownTicked(phoneNumber: phoneNumber, remainingTime: remainingTime));
      if (remainingTime <= 0) {
        timer.cancel();
      }
    });
  }
     void _onAuthFailure(AuthFailure event, Emitter<AuthState> emit) {
    emit(AuthError(message: event.message));
  }
  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}