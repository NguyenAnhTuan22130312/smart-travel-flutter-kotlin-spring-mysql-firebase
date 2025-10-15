 import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/destinations.dart';

abstract class DestinationRepository {
  Future<Either<Failure, List<DestinationEntity>>> getAllDestinationsFeatured();
}