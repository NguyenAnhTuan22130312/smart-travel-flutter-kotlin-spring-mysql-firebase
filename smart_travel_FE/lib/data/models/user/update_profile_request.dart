class UpdateProfileRequest {
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? country;

  const UpdateProfileRequest({
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

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (bio != null) 'bio': bio,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
    };
  }
}
