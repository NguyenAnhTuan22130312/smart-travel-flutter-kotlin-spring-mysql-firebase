import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<Either<Failure, User>> call({
    required int userId,
    String? fullName,
    String? phone,
    String? role,
  }) async {
    return await repository.updateUser(
      userId: userId,
      fullName: fullName,
      phone: phone,
      role: role,
    );
  }
}
