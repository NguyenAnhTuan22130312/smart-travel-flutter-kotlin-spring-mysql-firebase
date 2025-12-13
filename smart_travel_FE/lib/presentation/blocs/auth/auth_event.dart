import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/params/RegisterParams.dart';
import 'package:smart_travel/domain/params/login_params.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}
class AppStarted extends AuthEvent {}

class RegisterSubmitted extends AuthEvent {
  final RegisterParams params;

  const RegisterSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}

class LoginSubmitted extends AuthEvent {
  final LoginParams params;

  const LoginSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}
class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}
class GoogleLoginSubmitted extends AuthEvent {
  const GoogleLoginSubmitted();

  @override
  List<Object?> get props => [];
}

class FacebookLoginSubmitted extends AuthEvent {
  const FacebookLoginSubmitted();

  @override
  List<Object?> get props => [];
}

