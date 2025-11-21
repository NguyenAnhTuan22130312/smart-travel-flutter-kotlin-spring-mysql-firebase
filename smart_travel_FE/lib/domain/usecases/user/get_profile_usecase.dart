import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

class GetProfileUseCase {
  final UserRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getProfile();
  }
}

class UpdateProfileUseCase {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call({
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
    return await repository.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      bio: bio,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
      city: city,
      country: country,
    );
  }
}

class ChangePasswordUseCase {
  final UserRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    return await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}

class GetSettingsUseCase {
  final UserRepository repository;

  GetSettingsUseCase(this.repository);

  Future<Either<Failure, UserSettings>> call() async {
    return await repository.getSettings();
  }
}

class UpdateSettingsUseCase {
  final UserRepository repository;

  UpdateSettingsUseCase(this.repository);

  Future<Either<Failure, UserSettings>> call({
    String? languageSettings,
    bool? darkModeEnabled,
    String? notificationSettings,
  }) async {
    return await repository.updateSettings(
      languageSettings: languageSettings,
      darkModeEnabled: darkModeEnabled,
      notificationSettings: notificationSettings,
    );
  }
}

class GetLevelUseCase {
  final UserRepository repository;

  GetLevelUseCase(this.repository);

  Future<Either<Failure, UserLevel>> call() async {
    return await repository.getLevel();
  }
}

class UpdateLevelUseCase {
  final UserRepository repository;

  UpdateLevelUseCase(this.repository);

  Future<Either<Failure, UserLevel>> call({
    required int experiencePoints,
  }) async {
    return await repository.updateLevel(experiencePoints: experiencePoints);
  }
}

class DeleteAccountUseCase {
  final UserRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String confirmText,
    String? password,
    String? reason,
  }) async {
    return await repository.deleteAccount(
      confirmText: confirmText,
      password: password,
      reason: reason,
    );
  }
}

class LogoutUseCase {
  final UserRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
