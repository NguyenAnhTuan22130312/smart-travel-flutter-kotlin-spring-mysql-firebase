// core/network/interceptors/token_refresh_interceptor.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
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
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path.contains(ApiConstants.refreshToken)) {
      return handler.next(err);
    }

    try {
      final newToken = await _getNewToken();

      if (newToken == null) {
        // Nếu không có token mới, phải trả về lỗi kèm message từ BE
        return handler.reject(_createErrorWithBeMessage(err));
      }

      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newToken';

      // === XỬ LÝ LỖI FORM DATA FINALIZED ===
      if (requestOptions.data is FormData) {
        return handler.reject(DioException(
          requestOptions: requestOptions,
          error: ServerException("Phiên đăng nhập hết hạn hoặc bạn không có quyền truy cập. Vui lòng đăng nhập lại ."),
        ));
      }

      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);

    } catch (e) {
      return handler.reject(_createErrorWithBeMessage(err));
    }
  }

// Hàm bổ trợ để lấy message từ BE thay vì để 'null'
  DioException _createErrorWithBeMessage(DioException err) {
    String msg = "Phiên đăng nhập hết hạn";
    if (err.response?.data != null && err.response?.data is Map) {
      msg = err.response!.data['msg'] ?? msg;
    }
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: ServerException(msg),
      message: msg,
    );
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