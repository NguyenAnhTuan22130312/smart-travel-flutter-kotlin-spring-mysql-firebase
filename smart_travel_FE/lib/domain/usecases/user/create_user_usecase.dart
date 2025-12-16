import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class CreateUser {
  final UserRepository repository;

  CreateUser({required this.repository});

  Future<Either<Failure, User>> call({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required String role,
    String? gender,
    String? dateOfBirth,
    String? address,
    String? city,
    String? country,
    String? bio,
  }) async {
    return await repository.createUser(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      role: role,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
      city: city,
      country: country,
      bio: bio,
    );
  }
}
