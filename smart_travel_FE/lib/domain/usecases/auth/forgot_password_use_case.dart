import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase extends UseCase<String, String>{
  final AuthRepository authRepository;

  ForgotPasswordUseCase(this.authRepository);
  @override
  Future<Either<Failure, String>> call(String email) {
    return authRepository.forgotPassword(email);
  }

}