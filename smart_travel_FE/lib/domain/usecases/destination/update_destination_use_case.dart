import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/params/destination_update_params.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

class UpdateDestinationUseCase extends UseCase<DestinationEntity, DestinationUpdateParams>{
  final DestinationRepository destinationRepository;

  UpdateDestinationUseCase(this.destinationRepository);

  @override
  Future<Either<Failure, DestinationEntity>> call(DestinationUpdateParams params) {
    return destinationRepository.updateDestination(params);
  }

}