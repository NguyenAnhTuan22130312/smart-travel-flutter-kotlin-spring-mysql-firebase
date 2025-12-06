import 'package:equatable/equatable.dart';
import 'package:smart_travel/data/models/auth/login_response_modal.dart';
import 'package:smart_travel/data/models/auth/register_response_model.dart';
import 'package:smart_travel/domain/entities/auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class RegisterSuccess extends AuthState {
  final AuthEntity response;

  const RegisterSuccess(this.response);

  @override
  List<Object?> get props => [response];
}


class ResendVerificationSuccess extends AuthState {}

class LoginSuccess extends AuthState {
  final AuthEntity response;

  const LoginSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ForgotPasswordSuccess extends AuthState {
  final String response;

  const ForgotPasswordSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AdminAuthenticated extends AuthState {
  final String role;
  const AdminAuthenticated(this.role);

  @override
  List<Object?> get props => [role];
}
class UserAuthenticated extends AuthState {
  final String role;
  const UserAuthenticated(this.role);

  @override
  List<Object?> get props => [role];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}