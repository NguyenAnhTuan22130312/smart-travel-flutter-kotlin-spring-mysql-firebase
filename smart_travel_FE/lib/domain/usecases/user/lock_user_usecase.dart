import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class LockUser {
  final UserRepository repository;

  LockUser(this.repository);

  Future<Either<Failure, void>> call(int userId) async {
    return await repository.lockUser(userId);
  }
}
