import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';

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
}
