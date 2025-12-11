import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class UpdateLevelUseCase {
  final UserRepository repository;

  UpdateLevelUseCase(this.repository);

  Future<Either<Failure, UserLevel>> call({
    required int experiencePoints,
  }) async {
    return await repository.updateLevel(experiencePoints: experiencePoints);
  }
}
