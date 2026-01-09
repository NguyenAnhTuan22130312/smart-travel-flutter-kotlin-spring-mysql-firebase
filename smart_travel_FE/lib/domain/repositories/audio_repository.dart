import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import '../params/audio_params.dart';

abstract class AudioRepository {
  Future<Either<Failure, DestinationEntity>> addAudio(AudioParams params);
  Future<Either<Failure, DestinationEntity>> updateAudio(AudioParams params);
  Future<Either<Failure, DestinationEntity>> deleteAudio(int id);
}