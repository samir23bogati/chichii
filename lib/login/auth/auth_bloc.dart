import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    emit(PhoneAuthLoading());

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          emit(Authenticated(user: userCredential.user!));
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(message: e.message ?? "Verification failed."));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _startCountdown(event.phoneNumber, emit);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      emit(AuthError(message: 'Phone auth error: $e'));
    }
  }

  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(PhoneAuthLoading());

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: event.otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      emit(OtpVerified(user: userCredential.user!));
    } catch (e) {
      emit(AuthError(message: 'Invalid OTP: $e'));
    }
  }

  Future<void> _onResendOtpRequested(
      ResendOtpRequested event, Emitter<AuthState> emit) async {
    add(PhoneAuthRequested(phoneNumber: event.phoneNumber));
  }

  void _onCountdownTicked(
      CountdownTicked event, Emitter<AuthState> emit) {
    if (event.remainingTime > 0) {
      emit(OtpSentState(
          phoneNumber: event.phoneNumber, remainingTime: event.remainingTime));
    } else {
      _countdownTimer?.cancel();
    }
  }

  void _startCountdown(String phoneNumber, Emitter<AuthState> emit) {
    int remainingTime = 60;
    emit(OtpSentState(phoneNumber: phoneNumber, remainingTime: remainingTime));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      remainingTime--;
      add(CountdownTicked(phoneNumber: phoneNumber, remainingTime: remainingTime));
      if (remainingTime <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}