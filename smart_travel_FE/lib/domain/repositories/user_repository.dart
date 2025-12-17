import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/data/models/admin/admin_user_response.dart';

abstract class UserRepository {
  // Profile APIs
  Future<Either<Failure, User>> getProfile();

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
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  // Settings APIs
  Future<Either<Failure, UserSettings>> getSettings();

  Future<Either<Failure, UserSettings>> updateSettings({
    String? languageSettings,
    bool? darkModeEnabled,
    String? notificationSettings,
  });

  // Level APIs
  Future<Either<Failure, UserLevel>> getLevel();

  Future<Either<Failure, UserLevel>> updateLevel({
    required int experiencePoints,
  });

  // Account Management
  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> logout();

  // Admin: Get user list with pagination and search
  Future<Either<Failure, AdminUserResponse>> getUserList({
    int? page,
    int? size,
    String? searchKeyword,
    String? role,
    String? sortBy,
    String? sortDirection,
  });

  // Admin: Update user
  Future<Either<Failure, User>> updateUser({
    required int userId,
    String? fullName,
    String? phone,
    String? role,
  });

  // Admin: Lock user account
  Future<Either<Failure, void>> lockUser(int userId);

  // Admin: Unlock user account
  Future<Either<Failure, void>> unlockUser(int userId);

  // Admin: Create user
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
  });
}
