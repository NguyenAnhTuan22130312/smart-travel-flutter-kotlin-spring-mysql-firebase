import 'package:smart_travel/domain/entities/destination_image.dart';

class DestinationImageResponse {
  final int id;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;
  final DateTime? uploadedAt;

  DestinationImageResponse(
      this.id,
      this.imageUrl,
      this.isPrimary ,
      this.displayOrder,
      this.uploadedAt,
      );

  factory DestinationImageResponse.fromJson(Map<String, dynamic> json) {
    return DestinationImageResponse(
      json['id'] ?? 0,
      json['imageUrl'] ?? '',
      json['isPrimary'] ?? false,
      json['displayOrder'] ?? 0,
      json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : null,
    );
  }

  DestinationImage toEntity() {
    return DestinationImage(
      id: id,
      imageUrl: imageUrl,
      isPrimary: isPrimary,
      displayOrder: displayOrder,
      uploadedAt: uploadedAt,
    );
  }
}
