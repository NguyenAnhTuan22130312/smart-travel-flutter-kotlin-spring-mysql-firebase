import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

class DeleteDestinationUseCase extends UseCase<String, int>{
  final DestinationRepository destinationRepository;

  DeleteDestinationUseCase(this.destinationRepository);

  @override
  Future<Either<Failure, String>> call(int destinationId) {
    return destinationRepository.deleteDestination(destinationId);
  }

}