import 'package:smart_travel/domain/entities/province.dart';

class ProvinceModal {
  final int id;

  final String name;

  final String code;

  final String region;

  final String description;

  final String imageUrl;

  final bool isPopular;
  final int destinationCount;

  const ProvinceModal({
    required this.id,
    required this.name,
    required this.code,
    required this.region,
    required this.description,
    required this.imageUrl,
    required this.isPopular,
    required this.destinationCount,
  });

  //Chuyển từ json sang modal
  factory ProvinceModal.formJson(Map<String, dynamic> json) {
    return ProvinceModal(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      region: json['region'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isPopular: json['isPopular'] ?? false,
      destinationCount: json['destinationCount'] ?? 0,
    );
  }

  // chuyển từ modal sang entity
  ProvinceEntity toEntity() {
    return ProvinceEntity(
      id: id,
      name: name,
      code: code,
      region: region,
      description: description,
      imageUrl: imageUrl,
      isPopular: isPopular,
      destinationCount: destinationCount
    );
  }


}
