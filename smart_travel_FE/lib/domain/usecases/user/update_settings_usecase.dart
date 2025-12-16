import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/user.dart';
import 'package:smart_travel/domain/repositories/user_repository.dart';

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
