import 'package:equatable/equatable.dart';

class UserEntity extends Equatable{
  final String email;
  final String fullName;
  final String? phone;
  final bool? emailVerified;

  UserEntity({
    required this.email,
    required this.fullName,
    this.phone,
    required this.emailVerified,
  });

  @override
  List<Object?> get props => [email, fullName, phone, emailVerified];

}