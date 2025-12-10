import 'dart:io';

class ProvinceAddParams {
  final String name;
  final String code;
  final String region;
  final String? description;
  final bool isPopular;
  final File? image;

  ProvinceAddParams({
    required this.name,
    required this.code,
    required this.region,
    this.description,
    required this.isPopular,
    this.image,
  });
}