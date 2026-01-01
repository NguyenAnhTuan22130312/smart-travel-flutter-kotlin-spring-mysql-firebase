import 'package:smart_travel/domain/entities/tour_image.dart';

class TourImageModel {
  final int id;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;

  TourImageModel({
    required this.id,
    required this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
  });

  factory TourImageModel.fromJson(Map<String, dynamic> json) =>
      TourImageModel(
        id: json["id"] as int,
        imageUrl: json["imageUrl"] ?? '',
        isPrimary: json["isPrimary"] ?? false,
        displayOrder: json["displayOrder"] ?? 0,
      );

  TourImage toEntity() =>
      TourImage(
        id: id,
        imageUrl: imageUrl,
        isPrimary: isPrimary,
        displayOrder: displayOrder,
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "imageUrl": imageUrl,
      "isPrimary": isPrimary,
    };
  }
}