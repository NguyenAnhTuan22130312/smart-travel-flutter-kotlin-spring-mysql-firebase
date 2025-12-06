class ProvinceAddParams {
  final String name;
  final String code;
  final String region;
  final String? description;
  final bool isPopular;

  ProvinceAddParams({
    required this.name,
    required this.code,
    required this.region,
    this.description,
    required this.isPopular,
  });
}