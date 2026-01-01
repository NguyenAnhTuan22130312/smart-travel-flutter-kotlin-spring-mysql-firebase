import 'package:dio/dio.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/statistics/dashboard_stats.dart';

abstract class StatisticsRemoteDataSource {
  Future<DashboardStats> getDashboardStats();
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final DioClient dioClient;

  StatisticsRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await dioClient.get(ApiConstants.adminStatistics);

      if (response.data == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.adminStatistics),
          message: 'Response data is null',
          type: DioExceptionType.badResponse,
        );
      }

      // Response format: { "msg": "...", "data": { ... } }
      if (response.data['data'] != null) {
        return DashboardStats.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.adminStatistics),
          message: 'Statistics data is null in response',
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('Error in getDashboardStats: $e');
      rethrow;
    }
  }
}
