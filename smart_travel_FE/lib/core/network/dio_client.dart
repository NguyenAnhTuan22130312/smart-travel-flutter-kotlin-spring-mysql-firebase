import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(this._dio, this._storage) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = ApiConstants.connectionTimeout;
    _dio.options.receiveTimeout = ApiConstants.receiveTimeout;
    _dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';

    _dio.interceptors.add(AuthInterceptor(_storage));
    // Sửa: Thêm ErrorInterceptor
    _dio.interceptors.add(ErrorInterceptor());
  }

  Future<Response> get(String path) async {
    return _dio.get(path);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return _dio.delete(path, data: data);
  }
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    if (path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.register) ||
        path.contains(ApiConstants.forgotPassword)) {
      return handler.next(options);
    }

    // Key 'token' này phải khớp với key trong AuthLocalDataSource
    final String? token = await _storage.read(key: 'token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('Token attached to ${options.path}');
    } else {
      print('No token found for ${options.path}');
    }

    return handler.next(options);
  }
}

// --- Interceptor Xử lý Lỗi API (ĐÃ SỬA) ---
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // --- SỬA LỖI: Dùng handler.reject() thay vì throw ---
    // Điều này đảm bảo lỗi được Dio quản lý và trả về cho hàm .post()

    ServerException serverException;

    // Kiểm tra xem lỗi có phải là ServerException đã được đóng gói không
    // (Điều này xảy ra nếu một interceptor trước đó đã reject)
    if (err.error is ServerException) {
      return handler.reject(err); // Chỉ cần chuyển tiếp nó
    }

    if (err.response != null && err.response?.data != null && err.response?.data is Map) {
      // Lỗi từ backend (4xx, 5xx) VÀ có body JSON
      try {
        // Cố gắng đọc trường 'msg' từ JSON
        final errorMessage = err.response?.data['msg'] ?? 'Lỗi không xác định từ máy chủ';
        serverException = ServerException(errorMessage);
      } catch (e) {
        // Nếu body không phải là JSON hoặc không có 'msg'
        serverException = ServerException('Lỗi máy chủ không thể đọc: ${err.response?.data}');
      }
    } else if (err.type == DioExceptionType.connectionTimeout || err.type == DioExceptionType.receiveTimeout) {
      // Lỗi Timeout (Hết thời gian chờ)
      serverException = ServerException('Kết nối hết thời gian chờ. Vui lòng kiểm tra IP hoặc tường lửa.');
    }
    else {
      // Lỗi mạng (không có kết nối, không tìm thấy host) hoặc lỗi không xác định
      serverException = ServerException('Lỗi mạng hoặc không thể kết nối: ${err.message}');
    }

    // Trả về (reject) một DioException mới,
    // nhưng đính kèm ServerException (đã được chuẩn hóa) vào trường 'error'.
    return handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: serverException, // Đính kèm ServerException vào đây
    ));
  }
}
