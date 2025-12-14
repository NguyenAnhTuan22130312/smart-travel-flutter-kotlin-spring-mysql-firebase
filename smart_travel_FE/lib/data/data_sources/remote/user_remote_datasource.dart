import 'package:dio/dio.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/user/user_model.dart';
import 'package:smart_travel/data/models/user/user_level_model.dart';
import 'package:smart_travel/data/models/user/user_settings_model.dart';

import 'package:smart_travel/data/models/admin/admin_user_response.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<void> changePassword(Map<String, dynamic> data);
  Future<UserSettingsModel> getSettings();
  Future<UserSettingsModel> updateSettings(Map<String, dynamic> data);
  Future<UserLevelModel> getLevel();
  Future<UserLevelModel> updateLevel(Map<String, dynamic> data);
  Future<void> deleteAccount();

  // Admin: Get user list with pagination and search
  Future<AdminUserResponse> getUserList({
    int? page,
    int? size,
    String? searchKeyword,
    String? role,
    String? sortBy,
    String? sortDirection,
  });

  // Admin: Update user
  Future<UserModel> updateUser(int userId, Map<String, dynamic> data);

  // Admin: Lock user account
  Future<void> lockUser(int userId);

  // Admin: Unlock user account
  Future<void> unlockUser(int userId);

  // Admin: Create user
  Future<UserModel> createUser(Map<String, dynamic> data);
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
  Future<void> deleteAccount() async {
    try {
      final response = await dioClient.delete(ApiConstants.deleteAccount);

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

  @override
  Future<AdminUserResponse> getUserList({
    int? page,
    int? size,
    String? searchKeyword,
    String? role,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      // Build query string manually
      final StringBuffer queryString = StringBuffer('?');

      if (page != null) queryString.write('page=$page&');
      if (size != null) queryString.write('size=$size&');
      if (searchKeyword != null && searchKeyword.isNotEmpty) {
        queryString.write('searchKeyword=$searchKeyword&');
      }
      if (role != null && role.isNotEmpty) {
        queryString.write('role=$role&');
      }
      if (sortBy != null) queryString.write('sortBy=$sortBy&');
      if (sortDirection != null)
        queryString.write('sortDirection=$sortDirection&');

      // Remove trailing '&' or '?'
      String finalQuery = queryString.toString();
      if (finalQuery.endsWith('&')) {
        finalQuery = finalQuery.substring(0, finalQuery.length - 1);
      }
      if (finalQuery == '?') finalQuery = '';

      final response = await dioClient.get(
        '${ApiConstants.adminUsers}$finalQuery',
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.adminUsers),
          message: 'Response data is null',
          type: DioExceptionType.badResponse,
        );
      }

      if (response.data['code'] == 1000) {
        final data = response.data['data'];

        if (data == null) {
          throw DioException(
            requestOptions: RequestOptions(path: ApiConstants.adminUsers),
            message: 'User list data is null in response',
            type: DioExceptionType.badResponse,
          );
        }

        return AdminUserResponse.fromJson(data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.adminUsers),
          response: response,
          message: response.data['message'] ?? 'Failed to get user list',
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('Error in getUserList: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      // Remove null values
      data.removeWhere((key, value) => value == null);

      final response = await dioClient.put(
        '${ApiConstants.adminUserUpdate}$userId',
        data: data,
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: RequestOptions(
            path: '${ApiConstants.adminUserUpdate}$userId',
          ),
          message: 'Response data is null',
          type: DioExceptionType.badResponse,
        );
      }

      if (response.data['code'] == 1000) {
        final userData = response.data['data'];

        if (userData == null) {
          throw DioException(
            requestOptions: RequestOptions(
              path: '${ApiConstants.adminUserUpdate}$userId',
            ),
            message: 'User data is null in response',
            type: DioExceptionType.badResponse,
          );
        }

        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: RequestOptions(
            path: '${ApiConstants.adminUserUpdate}$userId',
          ),
          response: response,
          message: response.data['message'] ?? 'Failed to update user',
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('Error in updateUser: $e');
      rethrow;
    }
  }

  @override
  Future<void> lockUser(int userId) async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.adminUserLock}$userId/lock',
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: RequestOptions(
            path: '${ApiConstants.adminUserLock}$userId/lock',
          ),
          message: 'Response data is null',
          type: DioExceptionType.badResponse,
        );
      }

      if (response.data['code'] != 1000) {
        throw DioException(
          requestOptions: RequestOptions(
            path: '${ApiConstants.adminUserLock}$userId/lock',
          ),
          response: response,
          message: response.data['message'] ?? 'Failed to lock user',
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('Error in lockUser: $e');
      rethrow;
    }
  }

  @override
  Future<void> unlockUser(int userId) async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.adminUserUnlock}$userId/unlock',
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: RequestOptions(
            path: '${ApiConstants.adminUserUnlock}$userId/unlock',
          ),
          message: 'Response data is null',
          type: DioExceptionType.badResponse,
        );
      }

      if (response.data['code'] != 1000) {
        throw DioException(
          requestOptions: RequestOptions(
            path: '${ApiConstants.adminUserUnlock}$userId/unlock',
          ),
          response: response,
          message: response.data['message'] ?? 'Failed to unlock user',
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('Error in unlockUser: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    try {
      // Remove null values
      data.removeWhere((key, value) => value == null);

      final response = await dioClient.post(
        ApiConstants.adminUsers,
        data: data,
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.adminUsers),
          message: 'Response data is null',
          type: DioExceptionType.badResponse,
        );
      }

      if (response.data['code'] == 1000) {
        final userData = response.data['data'];

        if (userData == null) {
          throw DioException(
            requestOptions: RequestOptions(path: ApiConstants.adminUsers),
            message: 'User data is null in response',
            type: DioExceptionType.badResponse,
          );
        }

        return UserModel.fromJson(userData as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.adminUsers),
          response: response,
          message: response.data['message'] ?? 'Failed to create user',
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('Error in createUser: $e');
      rethrow;
    }
  }
}
