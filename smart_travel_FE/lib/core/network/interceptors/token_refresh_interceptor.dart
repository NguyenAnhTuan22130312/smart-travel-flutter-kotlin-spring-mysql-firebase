// core/network/interceptors/token_refresh_interceptor.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/domain/params/refresh_token_params.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class TokenRefreshInterceptor extends QueuedInterceptor {
  final AuthRepository authRepository;
  final AuthLocalDataSource localDataSource;
  final Dio dio;

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  TokenRefreshInterceptor({
    required this.authRepository,
    required this.localDataSource,
    required this.dio,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Chỉ xử lý 401 và không phải endpoint refresh token
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path.contains(ApiConstants.refreshToken)) {
      return handler.next(err);
    }

    try {
      // Lấy token mới (hoặc chờ nếu đang refresh)
      final newToken = await _getNewToken();

      if (newToken == null) {
        // Refresh thất bại → logout hoặc redirect to login
        return handler.reject(err);
      }

      // Retry request gốc với token mới
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newToken';

      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);

    } catch (e) {
      print('TokenRefreshInterceptor error: $e');
      return handler.reject(err);
    }
  }

  Future<String?> _getNewToken() async {
    // Nếu đang refresh, chờ kết quả
    if (_isRefreshing) {
      return await _refreshCompleter?.future;
    }

    // Bắt đầu refresh
    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final result = await authRepository.refreshToken(
        RefreshTokenParams(refreshToken: refreshToken),
      );

      String? newToken;
      result.fold(
            (failure) {
          print('Refresh token failed: ${failure.message}');
          throw Exception(failure.message);
        },
            (auth) {
          newToken = auth.token;
          if (newToken != null) {
            localDataSource.saveToken(newToken!);
          }
        },
      );

      // Hoàn thành completer với token mới
      _refreshCompleter?.complete(newToken);
      return newToken;

    } catch (e) {
      print('Error refreshing token: $e');
      _refreshCompleter?.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}