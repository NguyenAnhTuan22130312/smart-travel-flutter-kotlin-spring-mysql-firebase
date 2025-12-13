class UpdateLevelRequest {
  final int experiencePoints;

  const UpdateLevelRequest({required this.experiencePoints});

  Map<String, dynamic> toJson() {
    return {'experiencePoints': experiencePoints};
  }
}
