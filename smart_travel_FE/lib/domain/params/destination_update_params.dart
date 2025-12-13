import 'dart:io';

class DestinationUpdateParams {
  final int destinationId;
  final String? name;
  final int? provinceId;
  final String? description;
  final String? category;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double? entryFee;
  final String? openingHours;
  final bool? isFeatured;
  final List<File>? image;
  final List<int> imagesToDelete;

  DestinationUpdateParams({required this.name, required this.provinceId, required this.description, required this.category, required this.latitude, required this.longitude, required this.address, required this.entryFee, required this.openingHours, required this.isFeatured,
    required this.image, required this.destinationId, this.imagesToDelete = const []});

}