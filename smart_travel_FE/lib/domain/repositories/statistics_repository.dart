import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/models/statistics/dashboard_stats.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();
}
