import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class GetSettingsUseCase {
  final UserRepository repository;

  GetSettingsUseCase(this.repository);

  Future<Either<Failure, UserSettings>> call() async {
    return await repository.getSettings();
  }
}
