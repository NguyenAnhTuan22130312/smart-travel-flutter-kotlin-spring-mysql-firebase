import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final String authProvider;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;
  final String? bio;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? country;
  final String? notificationSettings;
  final String? languageSettings;
  final bool darkModeEnabled;
  final DateTime? profileUpdatedAt;
  final bool? isActive; // Admin: User account status
  final String? currentLevel; // User level from profile
  final int? experiencePoints; // Experience points from profile

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.authProvider,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.country,
    this.notificationSettings,
    this.languageSettings,
    required this.darkModeEnabled,
    this.profileUpdatedAt,
    this.isActive,
    this.currentLevel,
    this.experiencePoints,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phone,
    role,
    authProvider,
    emailVerified,
    createdAt,
    updatedAt,
    avatarUrl,
    bio,
    gender,
    dateOfBirth,
    address,
    city,
    country,
    notificationSettings,
    languageSettings,
    darkModeEnabled,
    profileUpdatedAt,
    isActive,
    currentLevel,
    experiencePoints,
  ];
}

class UserLevel extends Equatable {
  final String currentLevel;
  final int experiencePoints;
  final int? nextLevelAt;
  final double progressPercentage;
  final bool isLevelUp;
  final int earnedExp;
  final DateTime serverTime;

  const UserLevel( {
    required this.currentLevel,
    required this.experiencePoints,
    this.nextLevelAt,
    required this.progressPercentage,
    this.isLevelUp = false,
    required this.earnedExp,
    required this.serverTime,
  });

  @override
  List<Object?> get props => [
    currentLevel,
    experiencePoints,
    nextLevelAt,
    progressPercentage,
    isLevelUp,
    earnedExp,
    serverTime
  ];
}

class UserSettings extends Equatable {
  final String? languageSettings;
  final bool darkModeEnabled;
  final String? notificationSettings;

  const UserSettings({
    this.languageSettings,
    required this.darkModeEnabled,
    this.notificationSettings,
  });

  @override
  List<Object?> get props => [
    languageSettings,
    darkModeEnabled,
    notificationSettings,
  ];
}
