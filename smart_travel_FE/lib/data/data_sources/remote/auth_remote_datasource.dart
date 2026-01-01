import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/auth/facebook_login_request.dart';
import 'package:smart_travel/data/models/auth/google_login_request.dart';
import 'package:smart_travel/data/models/auth/login_request_modal.dart';
import 'package:smart_travel/data/models/auth/login_response_modal.dart';
import 'package:smart_travel/data/models/auth/refresh_token_request.dart';
import 'package:smart_travel/data/models/auth/register_request_model.dart';
import 'package:smart_travel/data/models/auth/register_response_model.dart';

abstract class AuthDataSource {
  /// Đăng ký người dùng mới
  Future<RegisterResponseModel> register(RegisterRequestModel request);

  /// Đăng nhập
  Future<LoginResponseModal> login(LoginRequestModal request);

  /// Refresh token
  Future<LoginResponseModal> refreshToken(RefreshTokenRequest refreshToken);

  /// Đăng nhập bằng gg
  Future<LoginResponseModal> googleLogin(GoogleLoginRequest  request);

  /// Đăng nhập bằng fb
  Future<LoginResponseModal> facebookLogin(FacebookLoginRequest  request);

  /// Quên mật khẩu
  Future<String> forgotPassword(String email);

}
class AuthRemoteDataSourceImpl implements AuthDataSource{
  final DioClient dio;

  AuthRemoteDataSourceImpl({required this.dio});



  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    // TODO: implement register
    try{
      final response = await dio
      .post(
       '${ApiConstants.baseUrl}${ApiConstants.register}',
        data: request.toJson(),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
          response.data,
              (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.data == null) {
          throw const ServerException('Không nhận được dữ liệu từ server');
        }

        return RegisterResponseModel.fromJson(apiResponse.data!);
      } else if (response.statusCode == 400) {
        final apiResponse = ApiResponseModel.fromJson(
          response.data,
          null,
        );
        throw ServerException(apiResponse.msg);
      } else {
        throw ServerException(
            'Đăng ký thất bại với mã lỗi: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Lỗi kết nối: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Đã xảy ra lỗi không mong muốn: ${e.toString()}');
    }
  }

  @override
  Future<LoginResponseModal> login(LoginRequestModal request) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
            (data) => data as Map<String, dynamic>,
      );
      return LoginResponseModal.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw NetworkException('Lỗi kết nối tới server');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  @override
  Future<String> forgotPassword(String email)async {
    // TODO: implement login
    try{
      final response = await dio
          .post('${ApiConstants.baseUrl}${ApiConstants.forgotPassword}?email=$email',
      ).timeout(ApiConstants.connectionTimeout);

      final apiResponse = response.data;
      final msg = apiResponse['msg'] ?? 'Không có thông báo từ server';
      return msg; // Trả message thành công
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw NetworkException('Lỗi kết nối tới server');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }
  @override
  Future<LoginResponseModal> googleLogin(GoogleLoginRequest  request)async {
    // TODO: implement login
    try{
      final response = await dio
          .post('${ApiConstants.baseUrl}${ApiConstants.googleLogin}',
          data: request.toJson(),
    ).timeout(ApiConstants.connectionTimeout);
        final responseBody = response.data;
        final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
          responseBody,
              (data) => data as Map<String, dynamic>);
        return LoginResponseModal.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw NetworkException('Lỗi kết nối tới server');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  @override
  Future<LoginResponseModal> facebookLogin(FacebookLoginRequest request)async {
// TODO: implement login
    try{
      final response = await dio
          .post('${ApiConstants.baseUrl}${ApiConstants.facebookLogin}',
        data: request.toJson(),
      ).timeout(ApiConstants.connectionTimeout);
        final responseBody =  response.data;
        final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
            responseBody,
                (data) => data as Map<String, dynamic>);
        return LoginResponseModal.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw NetworkException('Lỗi kết nối tới server');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  @override
  Future<LoginResponseModal> refreshToken(RefreshTokenRequest refreshToken) async {
    try {
      final response = await dio.post(
        ApiConstants.refreshToken,
        data: refreshToken.toJson(),
      );
      final json = response.data as Map<String, dynamic>;
      return LoginResponseModal.fromJson(json['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException("Lỗi không mong muốn: $e");
    }
  }
}
