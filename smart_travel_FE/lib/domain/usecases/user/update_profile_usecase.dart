import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? country,
  }) async {
    return await repository.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      bio: bio,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
      city: city,
      country: country,
    );
  }
}
