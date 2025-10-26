import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/auth.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class GoogleLoginUseCase implements UseCase<AuthEntity, NoParams> {
  final AuthRepository repository;

  GoogleLoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(NoParams params) async {
    return await repository.googleLogin();
  }
}