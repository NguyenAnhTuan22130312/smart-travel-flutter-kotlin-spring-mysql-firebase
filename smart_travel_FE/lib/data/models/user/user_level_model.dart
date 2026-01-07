import 'package:smart_travel/domain/entities/user.dart';

class UserLevelModel extends UserLevel {
  const UserLevelModel({
    required super.currentLevel,
    required super.experiencePoints,
    super.nextLevelAt,
    required super.progressPercentage,
    required super.isLevelUp,
    required super.earnedExp,
    required super.serverTime,
  });

  factory UserLevelModel.fromJson(Map<String, dynamic> json) {
    return UserLevelModel(
      currentLevel: json['currentLevel'] as String,
      experiencePoints: json['experiencePoints'] as int,
      nextLevelAt: json['nextLevelAt'] as int?,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      isLevelUp: json['isLevelUp'] ?? false,
      earnedExp: json['earnedExp'] as int,
      serverTime: DateTime.parse(json['serverTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'experiencePoints': experiencePoints,
      'nextLevelAt': nextLevelAt,
      'progressPercentage': progressPercentage,
      'isLevelUp': isLevelUp,
      'earnedExp' : earnedExp,
      'serverTime': serverTime,
    };
  }
}
