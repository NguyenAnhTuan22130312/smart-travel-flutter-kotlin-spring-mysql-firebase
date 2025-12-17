import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/user_remote_datasource.dart';
import 'package:smart_travel/data/models/admin/admin_user_response.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localStorage;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
  });

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? country,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (fullName != null) data['fullName'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (bio != null) data['bio'] = bio;
      if (gender != null) data['gender'] = gender;
      if (dateOfBirth != null) {
        data['dateOfBirth'] = dateOfBirth.toIso8601String().split('T')[0];
      }
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (country != null) data['country'] = country;

      final user = await remoteDataSource.updateProfile(data);
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await remoteDataSource.changePassword({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserSettings>> getSettings() async {
    try {
      final settings = await remoteDataSource.getSettings();
      return Right(settings);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserSettings>> updateSettings({
    String? languageSettings,
    bool? darkModeEnabled,
    String? notificationSettings,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (languageSettings != null) {
        data['languageSettings'] = languageSettings;
      }
      if (darkModeEnabled != null) {
        data['darkModeEnabled'] = darkModeEnabled;
      }
      if (notificationSettings != null) {
        data['notificationSettings'] = notificationSettings;
      }

      final settings = await remoteDataSource.updateSettings(data);
      return Right(settings);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserLevel>> getLevel() async {
    try {
      final level = await remoteDataSource.getLevel();
      return Right(level);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserLevel>> updateLevel({
    required int experiencePoints,
  }) async {
    try {
      final level = await remoteDataSource.updateLevel({
        'experiencePoints': experiencePoints,
      });
      return Right(level);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      await localStorage.clear();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localStorage.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Không thể đăng xuất'));
    }
  }

  @override
  Future<Either<Failure, AdminUserResponse>> getUserList({
    int? page,
    int? size,
    String? searchKeyword,
    String? role,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final result = await remoteDataSource.getUserList(
        page: page,
        size: size,
        searchKeyword: searchKeyword,
        role: role,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
      return Right(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure(message: 'Unauthorized access'));
      } else if (e.response?.statusCode == 403) {
        return const Left(
          AuthFailure(message: 'Forbidden: Admin access required'),
        );
      }
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to load users'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser({
    required int userId,
    String? fullName,
    String? phone,
    String? role,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (fullName != null) data['fullName'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (role != null) data['role'] = role;

      final result = await remoteDataSource.updateUser(userId, data);
      return Right(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure(message: 'Unauthorized access'));
      } else if (e.response?.statusCode == 403) {
        return const Left(
          AuthFailure(message: 'Forbidden: Admin access required'),
        );
      }
      return Left(
        ServerFailure(e.response?.data['msg'] ?? 'Failed to update user'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> lockUser(int userId) async {
    try {
      await remoteDataSource.lockUser(userId);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure(message: 'Unauthorized access'));
      } else if (e.response?.statusCode == 403) {
        return const Left(
          AuthFailure(message: 'Forbidden: Admin access required'),
        );
      }
      return Left(
        ServerFailure(e.response?.data['msg'] ?? 'Failed to lock user'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlockUser(int userId) async {
    try {
      await remoteDataSource.unlockUser(userId);
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure(message: 'Unauthorized access'));
      } else if (e.response?.statusCode == 403) {
        return const Left(
          AuthFailure(message: 'Forbidden: Admin access required'),
        );
      }
      return Left(
        ServerFailure(e.response?.data['msg'] ?? 'Failed to unlock user'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> createUser({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required String role,
    String? gender,
    String? dateOfBirth,
    String? address,
    String? city,
    String? country,
    String? bio,
  }) async {
    try {
      final data = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      };

      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (gender != null && gender.isNotEmpty) data['gender'] = gender;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        data['dateOfBirth'] = dateOfBirth;
      if (address != null && address.isNotEmpty) data['address'] = address;
      if (city != null && city.isNotEmpty) data['city'] = city;
      if (country != null && country.isNotEmpty) data['country'] = country;
      if (bio != null && bio.isNotEmpty) data['bio'] = bio;

      final result = await remoteDataSource.createUser(data);
      return Right(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure(message: 'Unauthorized access'));
      } else if (e.response?.statusCode == 403) {
        return const Left(
          AuthFailure(message: 'Forbidden: Admin access required'),
        );
      }
      return Left(
        ServerFailure(e.response?.data['msg'] ?? 'Failed to create user'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('msg')) {
        return ServerFailure(data['msg'] as String);
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Kết nối timeout');
      case DioExceptionType.badResponse:
        return ServerFailure('Lỗi từ server: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return ServerFailure('Request bị hủy');
      case DioExceptionType.connectionError:
        return ServerFailure('Lỗi kết nối');
      default:
        return ServerFailure('Đã xảy ra lỗi');
    }
  }
}
