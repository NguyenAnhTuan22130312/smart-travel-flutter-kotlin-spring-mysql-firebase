import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/auth.dart';
import 'package:smart_travel/domain/params/RegisterParams.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<AuthEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);
  @override
  Future<Either<Failure, AuthEntity>> call(RegisterParams params) {
    // TODO: implement call
    return repository.register(params);
  }
}

