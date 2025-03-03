// Abstract class for Auth States
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class GoogleAuthLoading extends AuthState {} 
class PhoneAuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  Authenticated({required this.user});
}
class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class OtpSentState extends AuthState {
  final String phoneNumber;
  OtpSentState({required this.phoneNumber});
}

class OtpVerified extends AuthState {
  final User user;
  OtpVerified({required this.user});
}
