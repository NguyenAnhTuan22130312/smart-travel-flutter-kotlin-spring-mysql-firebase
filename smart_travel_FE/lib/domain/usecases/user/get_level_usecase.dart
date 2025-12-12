import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class GetLevelUseCase {
  final UserRepository repository;

  GetLevelUseCase(this.repository);

  Future<Either<Failure, UserLevel>> call() async {
    return await repository.getLevel();
  }
}
