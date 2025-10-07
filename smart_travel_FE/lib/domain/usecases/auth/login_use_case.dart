import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/data/models/auth/login_request_modal.dart';
import 'package:smart_travel/data/models/auth/login_response_modal.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<LoginResponseModal, LoginRequestModal >{
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  @override
  Future<Either<Failure, LoginResponseModal>> call(LoginRequestModal params) {
    // TODO: implement call
    return authRepository.login(params);
  }

}