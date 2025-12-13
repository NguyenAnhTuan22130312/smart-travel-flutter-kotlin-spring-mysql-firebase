class UpdateSettingsRequest {
  final String? languageSettings;
  final bool? darkModeEnabled;
  final String? notificationSettings;

  const UpdateSettingsRequest({
    this.languageSettings,
    this.darkModeEnabled,
    this.notificationSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      if (languageSettings != null) 'languageSettings': languageSettings,
      if (darkModeEnabled != null) 'darkModeEnabled': darkModeEnabled,
      if (notificationSettings != null)
        'notificationSettings': notificationSettings,
    };
  }
}
