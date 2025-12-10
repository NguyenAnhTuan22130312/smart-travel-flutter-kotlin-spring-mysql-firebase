class ProvinceUpdateRequest {
  final String name;
  final String code;
  final String region;
  final String? description;
  final bool isPopular;

  ProvinceUpdateRequest({
    required this.name,
    required this.code,
    required this.region,
    this.description,
    required this.isPopular,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'region': region,
      'description': description,
      'isPopular': isPopular,
    };
  }
}