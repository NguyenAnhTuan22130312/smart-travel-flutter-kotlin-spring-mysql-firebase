import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/remote/audio_data_source.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/repositories/audio_repository.dart';
import '../../domain/params/audio_params.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AudioRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, DestinationEntity>> addAudio(AudioParams params) async {
    return await _getDestination(() async {
      final model = await remoteDataSource.addAudio(params);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, DestinationEntity>> updateAudio(AudioParams params) async {
    return await _getDestination(() async {
      final model = await remoteDataSource.updateAudio(params);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, DestinationEntity>> deleteAudio(int id) async {
    return await _getDestination(() async {
      final model = await remoteDataSource.deleteAudio(id);

      print("DELETE Result for ID $id: AudioScript = ${model.audioScript}");

      return model.toEntity();
    });
  }

  // Giữ nguyên hàm helper này
  Future<Either<Failure, DestinationEntity>> _getDestination(
      Future<DestinationEntity> Function() call) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await call();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
  }
}