import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

class GetAllDestinationsUseCase
    extends UseCase<List<DestinationEntity>, NoParams> {
  final DestinationRepository repository;

  GetAllDestinationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DestinationEntity>>> call(NoParams params) async {
    return await repository.getAllDestinations();
  }
}