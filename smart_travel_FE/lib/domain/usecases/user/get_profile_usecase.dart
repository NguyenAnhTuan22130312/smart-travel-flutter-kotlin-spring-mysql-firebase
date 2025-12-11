import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class GetProfileUseCase {
  final UserRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getProfile();
  }
}
