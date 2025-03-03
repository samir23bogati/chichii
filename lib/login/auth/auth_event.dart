// Abstract class for Auth Events
abstract class AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}


class PhoneAuthRequested extends AuthEvent {
  final String phoneNumber;

  PhoneAuthRequested(this.phoneNumber);
}

class VerifyOtpRequested extends AuthEvent {
  final String otp;

  VerifyOtpRequested(this.otp);
}

class OtpSent extends AuthEvent {  
  final String phoneNumber;
  OtpSent({required this.phoneNumber});
}
