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
  final String? audioScript;


  DestinationUpdateParams({
    required this.destinationId, // Chỉ giữ lại ID là bắt buộc
    this.name,
    this.provinceId,
    this.description,
    this.category,
    this.latitude,
    this.longitude,
    this.address,
    this.entryFee,
    this.openingHours,
    this.isFeatured,
    this.image,
    this.audioScript, // THÊM DÒNG NÀY
    this.imagesToDelete = const [],
  });
}