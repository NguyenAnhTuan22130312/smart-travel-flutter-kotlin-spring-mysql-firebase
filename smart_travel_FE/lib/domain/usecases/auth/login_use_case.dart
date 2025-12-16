import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/auth.dart';
import 'package:smart_travel/domain/params/login_params.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthEntity, LoginParams >{
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams  params) {
    // TODO: implement call
    return authRepository.login(params);
  }

}
