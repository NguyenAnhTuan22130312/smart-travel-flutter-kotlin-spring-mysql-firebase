import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/auth.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class FacebookLoginUseCase extends UseCase<AuthEntity, NoParams>{
  final AuthRepository authRepository;

  FacebookLoginUseCase(this.authRepository);
  @override
  Future<Either<Failure, AuthEntity>> call(NoParams params) {
    return authRepository.facebookLogin();
  }

}