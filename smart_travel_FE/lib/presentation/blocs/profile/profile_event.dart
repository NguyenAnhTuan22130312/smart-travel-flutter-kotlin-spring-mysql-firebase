import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// Load Profile Event
class LoadProfile extends ProfileEvent {}

// Update Profile Event
class UpdateProfile extends ProfileEvent {
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? country;

  const UpdateProfile({
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.country,
  });

  @override
  List<Object?> get props => [
        fullName,
        phone,
        avatarUrl,
        bio,
        gender,
        dateOfBirth,
        address,
        city,
        country,
      ];
}

// Change Password Event
class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmNewPassword];
}

// Load Settings Event
class LoadSettings extends ProfileEvent {}

// Update Settings Event
class UpdateSettings extends ProfileEvent {
  final Map<String, dynamic>? languageSettingsMap;
  final bool? darkModeEnabled;
  final Map<String, dynamic>? notificationSettingsMap;

  const UpdateSettings({
    this.languageSettingsMap,
    this.darkModeEnabled,
    this.notificationSettingsMap,
  });

  @override
  List<Object?> get props => [
        languageSettingsMap,
        darkModeEnabled,
        notificationSettingsMap,
      ];
}

// Load Level Event
class LoadLevel extends ProfileEvent {}

// Delete Account Event
class DeleteAccount extends ProfileEvent {}

// Logout Event
class Logout extends ProfileEvent {}
