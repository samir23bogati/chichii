import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? verificationId;

  AuthBloc() : super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<PhoneAuthRequested>(_onPhoneAuthRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<OtpSent>(_onOtpSent);
    on<CheckAuthStatus>(_onCheckAuthStatus);
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
      emit(AuthError(message: e.toString()));
    }
  }

  // ✅ OTP Sent Handling
  void _onOtpSent(OtpSent event, Emitter<AuthState> emit) {
    emit(OtpSentState(phoneNumber: event.phoneNumber));
  }

  // ✅ Function to Verify OTP
  Future<User?> _verifyOtp(String otp) async {
    if (verificationId != null) {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

      return userCredential.user;
    } else {
      throw Exception('Verification ID is missing');
    }
  }

  // ✅ Function to Send OTP
  Future<void> _sendPhoneNumber(String phoneNumber) async {
    if (phoneNumber.isNotEmpty && phoneNumber.length == 10) {
      final formattedPhoneNumber = '+977$phoneNumber';

      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          add(OtpSent(phoneNumber: phoneNumber));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } else {
      throw Exception('Please enter a valid phone number');
    }
  }
}
