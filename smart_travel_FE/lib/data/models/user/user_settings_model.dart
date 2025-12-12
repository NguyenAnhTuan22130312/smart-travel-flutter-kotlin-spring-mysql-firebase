import 'package:smart_travel/domain/entities/user.dart';

class UserSettingsModel extends UserSettings {
  const UserSettingsModel({
    super.languageSettings,
    required super.darkModeEnabled,
    super.notificationSettings,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      languageSettings: json['languageSettings'] as String?,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      notificationSettings: json['notificationSettings'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageSettings': languageSettings,
      'darkModeEnabled': darkModeEnabled,
      'notificationSettings': notificationSettings,
    };
  }
}
