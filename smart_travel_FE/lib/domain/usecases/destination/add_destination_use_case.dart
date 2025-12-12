import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/params/destination_add_params.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

class AddDestinationUseCase extends UseCase<DestinationEntity, DestinationAddParams>{
  final DestinationRepository destinationRepository;
  AddDestinationUseCase(this.destinationRepository);

  @override
  Future<Either<Failure, DestinationEntity>> call(DestinationAddParams params) {
    return destinationRepository.addDestination(params);
  }
  
}