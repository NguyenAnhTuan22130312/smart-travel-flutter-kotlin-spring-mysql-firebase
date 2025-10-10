import 'package:equatable/equatable.dart';
import 'package:smart_travel/data/models/auth/login_request_modal.dart';
import 'package:smart_travel/data/models/auth/register_request_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}
class AppStarted extends AuthEvent {}

class RegisterSubmitted extends AuthEvent {
  final RegisterRequestModel request;

  const RegisterSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class LoginSubmitted extends AuthEvent {
  final LoginRequestModal requestModal;

  const LoginSubmitted(this.requestModal);

  @override
  List<Object?> get props => [requestModal];
}
class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}

