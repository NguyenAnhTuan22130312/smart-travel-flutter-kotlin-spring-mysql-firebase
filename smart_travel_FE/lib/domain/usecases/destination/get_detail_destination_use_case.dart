import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

class GetDetailDestinationUseCase extends UseCase<DestinationEntity, int>{
  final DestinationRepository destinationRepository;

  GetDetailDestinationUseCase(this.destinationRepository);

  @override
  Future<Either<Failure, DestinationEntity>> call(int params) {
    return destinationRepository.getDestinationDetail(params);
  }

}
