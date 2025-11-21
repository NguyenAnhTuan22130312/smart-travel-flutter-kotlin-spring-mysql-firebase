import 'package:dio/dio.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/user/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<void> changePassword(Map<String, dynamic> data);
  Future<UserSettingsModel> getSettings();
  Future<UserSettingsModel> updateSettings(Map<String, dynamic> data);
  Future<UserLevelModel> getLevel();
  Future<UserLevelModel> updateLevel(Map<String, dynamic> data);
  Future<void> deleteAccount({
    required String confirmText,
    String? password,
    String? reason,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient dioClient;

  UserRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dioClient.get(ApiConstants.getProfile);

      if (response.data == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.getProfile),
          message: 'Response data is null',
          type: DioExceptionType.badResponse,
        );
      }

      if (response.data['code'] == 1000) {
        final data = response.data['data'];
        
        if (data == null) {
          throw DioException(
            requestOptions: RequestOptions(path: ApiConstants.getProfile),
            message: 'Profile data is null in response',
            type: DioExceptionType.badResponse,
          );
        }
        
        // Debug: Print response data
        print('Profile API Response: ${response.data}');
        
        return UserModel.fromJson(data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.getProfile),
          response: response,
          message: response.data['message'] ?? 'Failed to get profile',
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('Error in getProfile: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      // Loại bỏ các field null
      data.removeWhere((key, value) => value == null);

      final response = await dioClient.put(
        ApiConstants.updateProfile,
        data: data,
      );

      if (response.data['code'] == 1000) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.updateProfile),
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        ApiConstants.changePassword,
        data: data,
      );

      if (response.data['code'] != 1000) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.changePassword),
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserSettingsModel> getSettings() async {
    try {
      final response = await dioClient.get(ApiConstants.getSettings);

      if (response.data['code'] == 1000) {
        return UserSettingsModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.getSettings),
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserSettingsModel> updateSettings(Map<String, dynamic> data) async {
    try {
      data.removeWhere((key, value) => value == null);

      final response = await dioClient.put(
        ApiConstants.updateSettings,
        data: data,
      );

      if (response.data['code'] == 1000) {
        return UserSettingsModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.updateSettings),
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserLevelModel> getLevel() async {
    try {
      final response = await dioClient.get(ApiConstants.getLevel);

      if (response.data['code'] == 1000) {
        return UserLevelModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.getLevel),
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserLevelModel> updateLevel(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        ApiConstants.updateLevel,
        data: data,
      );

      if (response.data['code'] == 1000) {
        return UserLevelModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.updateLevel),
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount({
    required String confirmText,
    String? password,
    String? reason,
  }) async {
    try {
      final data = <String, dynamic>{
        'confirmText': confirmText,
      };
      
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      if (reason != null && reason.isNotEmpty) {
        data['reason'] = reason;
      }

      final response = await dioClient.delete(
        ApiConstants.deleteAccount,
        data: data,
      );

      if (response.data['code'] != 1000) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}