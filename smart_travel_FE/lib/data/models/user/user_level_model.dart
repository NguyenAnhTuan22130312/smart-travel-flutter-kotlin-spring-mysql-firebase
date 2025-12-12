import 'package:smart_travel/domain/entities/user.dart';

class UserLevelModel extends UserLevel {
  const UserLevelModel({
    required super.currentLevel,
    required super.experiencePoints,
    super.nextLevelAt,
    required super.progressPercentage,
  });

  factory UserLevelModel.fromJson(Map<String, dynamic> json) {
    return UserLevelModel(
      currentLevel: json['currentLevel'] as String,
      experiencePoints: json['experiencePoints'] as int,
      nextLevelAt: json['nextLevelAt'] as int?,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'experiencePoints': experiencePoints,
      'nextLevelAt': nextLevelAt,
      'progressPercentage': progressPercentage,
    };
  }
}
