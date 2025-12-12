import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class UnlockUser {
  final UserRepository repository;

  UnlockUser(this.repository);

  Future<Either<Failure, void>> call(int userId) async {
    return await repository.unlockUser(userId);
  }
}
