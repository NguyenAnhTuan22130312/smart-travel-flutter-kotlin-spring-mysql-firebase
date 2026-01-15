import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/data/models/user/user_level_model.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

class CompleteVoiceUseCase implements UseCase<UserLevelModel, int> {
  final DestinationRepository repository;
  CompleteVoiceUseCase(this.repository);

  @override
  Future<Either<Failure, UserLevelModel>> call(int destinationId) async {
    return await repository.completeVoice(destinationId);
  }
}