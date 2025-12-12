 import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/params/destination_add_params.dart';
import 'package:smart_travel/domain/params/destination_update_params.dart';

abstract class DestinationRepository {
  Future<Either<Failure, List<DestinationEntity>>> getAllDestinationsFeatured();
  Future<Either<Failure, List<DestinationEntity>>> getAllDestinations();
  Future<Either<Failure, List<DestinationEntity>>> filterDestinationsByCategory( String category);
  Future<Either<Failure, DestinationEntity>> getDestinationDetail(int id);
  Future<Either<Failure, DestinationEntity>> addDestination(DestinationAddParams params);
  Future<Either<Failure, DestinationEntity>> updateDestination(DestinationUpdateParams params);
  Future<Either<Failure, String>> deleteDestination(int destinationId);
}