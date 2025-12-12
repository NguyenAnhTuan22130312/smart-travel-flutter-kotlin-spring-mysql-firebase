import 'package:smart_travel/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    required super.role,
    required super.authProvider,
    required super.emailVerified,
    required super.createdAt,
    required super.updatedAt,
    super.avatarUrl,
    super.bio,
    super.gender,
    super.dateOfBirth,
    super.address,
    super.city,
    super.country,
    super.notificationSettings,
    super.languageSettings,
    required super.darkModeEnabled,
    super.profileUpdatedAt,
    super.isActive,
    super.currentLevel,
    super.experiencePoints,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'USER',
      authProvider: json['authProvider'] as String? ?? 'LOCAL',
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      notificationSettings: json['notificationSettings'] as String?,
      languageSettings: json['languageSettings'] as String?,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      profileUpdatedAt:
          json['profileUpdatedAt'] != null
              ? DateTime.parse(json['profileUpdatedAt'] as String)
              : null,
      isActive: json['isActive'] as bool?,
      currentLevel: json['currentLevel'] as String?,
      experiencePoints: json['experiencePoints'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'authProvider': authProvider,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'bio': bio,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'city': city,
      'country': country,
      'notificationSettings': notificationSettings,
      'languageSettings': languageSettings,
      'darkModeEnabled': darkModeEnabled,
      'profileUpdatedAt': profileUpdatedAt?.toIso8601String(),
      'isActive': isActive,
      'currentLevel': currentLevel,
      'experiencePoints': experiencePoints,
    };
  }
}
