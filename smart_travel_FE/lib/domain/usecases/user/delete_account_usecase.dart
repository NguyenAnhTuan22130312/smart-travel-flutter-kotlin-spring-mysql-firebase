import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class DeleteAccountUseCase {
  final UserRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.deleteAccount();
  }
}
