import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/data/models/auth/register_request_model.dart';
import 'package:smart_travel/data/models/auth/register_response_model.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<RegisterResponseModel, RegisterRequestModel> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);
  @override
  Future<Either<Failure, RegisterResponseModel>> call(RegisterRequestModel params) {
    // TODO: implement call
    return repository.register(params);
  }
}