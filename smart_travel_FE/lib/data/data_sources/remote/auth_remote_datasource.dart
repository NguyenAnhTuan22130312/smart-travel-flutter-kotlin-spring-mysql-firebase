import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/auth/login_request_modal.dart';
import 'package:smart_travel/data/models/auth/login_response_modal.dart';
import 'package:smart_travel/data/models/auth/register_request_model.dart';
import 'package:smart_travel/data/models/auth/register_response_model.dart';

abstract class AuthDataSource {
  /// Đăng ký người dùng mới
  Future<RegisterResponseModel> register(RegisterRequestModel request);

  /// Đăng nhập
  Future<LoginResponseModal> login(LoginRequestModal request);
}
class AuthRemoteDataSourceImpl implements AuthDataSource{
  final http.Client client;
  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    // TODO: implement register
    try{
      final response = await client
      .post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: {
          'Content-Type': 'application/json',

        },
        body: jsonEncode(request.toJson()),
        
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
          jsonDecode(response.body),
              (data) => data as Map<String, dynamic>,
        );

        if (apiResponse.data == null) {
          throw const ServerException('Không nhận được dữ liệu từ server');
        }

        return RegisterResponseModel.fromJson(apiResponse.data!);
      } else if (response.statusCode == 400) {
        final apiResponse = ApiResponseModel.fromJson(
          jsonDecode(response.body),
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
  Future<LoginResponseModal> login(LoginRequestModal request)async {
    // TODO: implement login
    try{
      final response = await client
          .post(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
          headers: {
            'Content-Type': 'application/json',
      },
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConstants.connectionTimeout);

      if(response.statusCode == 200) {
        final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
          jsonDecode(response.body),
              (data) => data as Map<String, dynamic>,
        );
        if (apiResponse.data == null) {
          throw const ServerException('Không nhận được dữ liệu từ server');
        }
        return LoginResponseModal.fromJson(apiResponse.data!);
      }
      else if (response.statusCode == 400) {
        final apiResponse = ApiResponseModel.fromJson(
          jsonDecode(response.body),
          null,
        );
        throw ServerException(apiResponse.msg);
      } else {
        throw ServerException(
            'Đăng nhập thất bại với mã lỗi: ${response.statusCode}');
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
}
