import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class DioClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  DioClient({required this.storage})
      : dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
    },

  )) {
    // Chỉ thêm 2 interceptor cơ bản trước
    // dio.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    //   error: true,
    //   requestHeader: true,
    //   logPrint: (log) => print('DIO: $log'),
    // ));

    dio.interceptors.add(AuthInterceptor(storage));
    dio.interceptors.add(ErrorInterceptor());
  }

  // ===  THÊM REFRESH TOKEN INTERCEPTOR SAU KHI GetIt ĐÃ SẴN SÀNG ===
  void addRefreshTokenInterceptor({
    required AuthRepository authRepository,
    required AuthLocalDataSource localDataSource,
  }) {
    // Nếu đã thêm rồi thì không thêm lại
    if (dio.interceptors.any((i) => i is TokenRefreshInterceptor)) return;

    dio.interceptors.insert(
      dio.interceptors.length - 1,
      TokenRefreshInterceptor(
        authRepository: authRepository,
        localDataSource: localDataSource,
        dio: dio,
      ),
    );
  }

  // Helper methods (có thể gọi từ mọi nơi)
  Future<Response<T>> get<T>(String path, {Options? options}) =>
      dio.get<T>(path, options: options);

  Future<Response<T>> post<T>(String path, {dynamic data, Options? options}) =>
      dio.post<T>(path, data: data, options: options);

  Future<Response<T>> put<T>(String path, {dynamic data, Options? options}) =>
      dio.put<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(String path, {Options? options}) =>
      dio.delete<T>(path, options: options);
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  static const List<String> _noTokenEndpoints = [
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.forgotPassword,
    ApiConstants.refreshToken,
  ];

  AuthInterceptor(this._storage);


  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    // Skip các endpoint không cần token
    if (_noTokenEndpoints.any((endpoint) => path.contains(endpoint))) {
      print('Skip token for: ${options.path}');
      return handler.next(options);
    }

    // Lấy token từ storage
    final String? token = await _storage.read(key: 'token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('Token attached to ${options.path}');
    } else {
      print('No token found for ${options.path}');
    }

    handler.next(options);
  }
}




// --- Interceptor Xử lý Lỗi API  ---
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'Lỗi không xác định';

    if (err.response != null) {
      final data = err.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['msg'] ?? data['message'] ?? 'Lỗi từ server';
      } else if (data is String) {
        message = data;
      } else {
        message = 'Lỗi server: ${err.response!.statusCode}';
      }
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = 'Kết nối timeout. Kiểm tra mạng hoặc server!';
    } else if (err.type == DioExceptionType.badResponse) {
      message = 'Lỗi phản hồi: ${err.response?.statusCode}';
    } else {
      message = 'Không có kết nối mạng';
    }

    final serverException = ServerException(message);
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: serverException,
      message: message,
    );

    handler.reject(newError);
  }
}
