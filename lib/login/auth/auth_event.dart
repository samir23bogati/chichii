// Abstract class for Auth Events
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GoogleSignInRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}


class PhoneAuthRequested extends AuthEvent {
  final String phoneNumber;
  PhoneAuthRequested({required this.phoneNumber});
}

class VerifyOtpRequested extends AuthEvent {
  final String otp;
  VerifyOtpRequested({required this.otp});
}

class OtpSent extends AuthEvent {  
  final String phoneNumber;
  final int remainingTime;
  OtpSent({required this.phoneNumber,required this.remainingTime});
}
class AuthSuccess extends AuthEvent {}

class AuthFailure extends AuthEvent {
  final String message;
  
  AuthFailure({required this.message});
}
class ResendOtpRequested extends AuthEvent {
  final String phoneNumber;
  ResendOtpRequested({required this.phoneNumber});
}

class CountdownTicked extends AuthEvent {
  final String phoneNumber;
  final int remainingTime;
  CountdownTicked({required this.phoneNumber, required this.remainingTime});

  @override
  List<Object?> get props => [phoneNumber, remainingTime];
}
