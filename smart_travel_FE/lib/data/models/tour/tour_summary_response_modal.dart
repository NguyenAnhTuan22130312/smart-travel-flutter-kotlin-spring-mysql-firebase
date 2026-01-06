import 'package:smart_travel/domain/entities/tour.dart';

class TourSummaryResponse {
  final int id;
  final String name;
  final int? durationDays;
  final double pricePerPerson;
  final double? averageRating;
  final int? reviewCount;
  final String? images; // Ảnh đầu tiên

  TourSummaryResponse({
    required this.id,
    required this.name,
    this.durationDays,
    required this.pricePerPerson,
    this.averageRating,
    this.reviewCount,
    this.images,
  });

  factory TourSummaryResponse.fromJson(Map<String, dynamic> json) {
    return TourSummaryResponse(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      durationDays: json['durationDays'] as int?,
      pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : null,
      reviewCount: json['reviewCount'] as int?,
      images: (json['images'] ?? json['thumbnail']) as String?,
    );
  }

  Tour toEntity() {
    return  Tour(
      id: id,
      name: name,
      durationDays: durationDays,
      pricePerPerson: pricePerPerson,
      averageRating: averageRating,
      reviewCount: reviewCount,
      image: images,
    );
  }
}