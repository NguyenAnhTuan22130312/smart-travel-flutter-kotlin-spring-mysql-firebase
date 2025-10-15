import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

class GetAllDestinationFeaturedUseCase implements UseCase<List<DestinationEntity>, NoParams>{
  final DestinationRepository destinationRepository;

  GetAllDestinationFeaturedUseCase(this.destinationRepository);
  @override
  Future<Either<Failure, List<DestinationEntity>>> call(NoParams params) {
    // TODO: implement call
    return destinationRepository.getAllDestinationsFeatured();
  }


}