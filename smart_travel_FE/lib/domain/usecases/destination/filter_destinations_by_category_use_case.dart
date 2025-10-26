import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

class FilterDestinationsByCategoryUseCase
    extends UseCase<List<DestinationEntity>, String> {
  final DestinationRepository repository;

  FilterDestinationsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<DestinationEntity>>> call(
      String category) async {
    return await repository.filterDestinationsByCategory(category);
  }
}