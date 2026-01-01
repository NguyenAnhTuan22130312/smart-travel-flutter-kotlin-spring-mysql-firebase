import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/data_sources/remote/statistics_data_source.dart';
import 'package:smart_travel/data/models/statistics/dashboard_stats.dart';
import 'package:smart_travel/domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final stats = await remoteDataSource.getDashboardStats();
      return Right(stats);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
