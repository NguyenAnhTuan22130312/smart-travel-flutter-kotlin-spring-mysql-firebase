import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

// Initial State
class ProfileInitial extends ProfileState {}

// Loading State
class ProfileLoading extends ProfileState {}

// Profile Loaded State
class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

// Profile Update Success State
class ProfileUpdateSuccess extends ProfileState {
  final User user;
  final String message;

  const ProfileUpdateSuccess(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

// Password Change Success State
class PasswordChangeSuccess extends ProfileState {
  final String message;

  const PasswordChangeSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Settings Loaded State
class SettingsLoaded extends ProfileState {
  final UserSettings settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

// Settings Update Success State
class SettingsUpdateSuccess extends ProfileState {
  final UserSettings settings;
  final String message;

  const SettingsUpdateSuccess(this.settings, this.message);

  @override
  List<Object?> get props => [settings, message];
}

// Level Loaded State
class LevelLoaded extends ProfileState {
  final UserLevel level;

  const LevelLoaded(this.level);

  @override
  List<Object?> get props => [level];
}

// Account Deleted Success State
class AccountDeletedSuccess extends ProfileState {
  final String message;

  const AccountDeletedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Logout Success State
class LogoutSuccess extends ProfileState {
  final UserSettings? defaultSettings;

  const LogoutSuccess({this.defaultSettings});

  @override
  List<Object?> get props => [defaultSettings];
}

// Error State
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
