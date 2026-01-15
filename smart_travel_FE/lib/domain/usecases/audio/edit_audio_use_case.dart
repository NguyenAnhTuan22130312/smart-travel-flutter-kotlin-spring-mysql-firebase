import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/params/audio_params.dart';
import 'package:smart_travel/domain/repositories/audio_repository.dart';

class EditAudioUseCase implements UseCase<DestinationEntity, AudioParams> {
  final AudioRepository repository;
  EditAudioUseCase(this.repository);
  @override
  Future<Either<Failure, DestinationEntity>> call(AudioParams params) async => await repository.updateAudio(params);
}