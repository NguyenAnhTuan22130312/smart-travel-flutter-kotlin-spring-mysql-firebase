import 'package:smart_travel/domain/entities/destinations.dart';

class ProvinceEntity {
  final int id;

  final String name;

  final String code;

  final String region;

  final String description;

  final String imageUrl;

  final bool isPopular;

  final int? destinationCount;

  final List<DestinationEntity>? destination ;

  ProvinceEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.region,
    required this.description,
    required this.imageUrl,
    required this.isPopular,
    this.destination,
    this.destinationCount,
  });
}