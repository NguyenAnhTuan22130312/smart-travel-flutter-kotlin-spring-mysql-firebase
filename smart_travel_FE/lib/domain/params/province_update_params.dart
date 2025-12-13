import 'dart:io';

class ProvinceUpdateParams{
  final int provinceId;
  final String name;
  final String code;
  final String region;
  final String? description;
  final bool isPopular;
  final File? image;

  ProvinceUpdateParams({
    required this.provinceId,
    required this.name,
    required this.code,
    required this.region,
    this.description,
    required this.isPopular,
    this.image,
  });

}