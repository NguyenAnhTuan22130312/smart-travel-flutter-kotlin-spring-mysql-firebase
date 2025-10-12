import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final int? userId;
  final String? email;
  final String? fullName;
  final String? message;
  final String? token;
  final String? refreshToken;
  final String? role;

  const AuthEntity({
    this.userId,
    this.email,
    this.fullName,
    this.message,
    this.token,
    this.refreshToken,
    this.role,
  });

  @override
  List<Object?> get props => [
    userId,
    email,
    fullName,
    message,
    token,
    refreshToken,
    role,
  ];
}
