import 'package:smart_travel/data/models/destination/destination_response_modal.dart';
import 'package:smart_travel/domain/entities/province.dart';

class ProvinceDetailResponseModal {
  final int id;

  final String name;

  final String code;

  final String region;

  final String description;

  final String imageUrl;

  final bool isPopular;
  final int destinationCount;
  final List<DestinationResponseModal> destinations;

  const ProvinceDetailResponseModal({
    required this.id,
    required this.name,
    required this.code,
    required this.region,
    required this.description,
    required this.imageUrl,
    required this.isPopular,
    required this.destinationCount,
    required this.destinations
  });

  //Chuyển từ json sang modal
  factory ProvinceDetailResponseModal.formJson(Map<String, dynamic> json) {
    return ProvinceDetailResponseModal(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      region: json['region'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isPopular: json['isPopular'] ?? false,
      destinationCount: json['destinationCount'] ?? 0,
      destinations: (json['destinations'] as List<dynamic>?)
          ?.map((e) => DestinationResponseModal.fromJson(e))
          .toList() ?? [],
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
        destinationCount: destinationCount,
        destination: destinations.map((d) => d.toEntity()).toList(),
    );
  }


}
