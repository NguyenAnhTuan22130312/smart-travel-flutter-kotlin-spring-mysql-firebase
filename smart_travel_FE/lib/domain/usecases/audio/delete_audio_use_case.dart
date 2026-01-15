import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/repositories/audio_repository.dart';

class DeleteAudioUseCase implements UseCase<DestinationEntity, int> {
  final AudioRepository repository;
  DeleteAudioUseCase(this.repository);
  @override
  Future<Either<Failure, DestinationEntity>> call(int id) async => await repository.deleteAudio(id);
}