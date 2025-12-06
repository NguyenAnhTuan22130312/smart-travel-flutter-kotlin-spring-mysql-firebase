import 'package:smart_travel/domain/entities/hotel.dart';

class HotelSummaryResponse {
  final int id;
  final String name;
  final String address;
  final double pricePerNight;
  final int? starRating;
  final double? averageRating;
  final String? images; // Ảnh đầu tiên

  HotelSummaryResponse({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerNight,
    this.starRating,
    this.averageRating,
    this.images,
  });

  factory HotelSummaryResponse.fromJson(Map<String, dynamic> json) {
    return HotelSummaryResponse(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      starRating: json['starRating'] as int?,
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : null,
      images: json['images'] as String?,
    );
  }

  Hotel toEntity() {
    return Hotel (
      id: id,
      name: name,
      address: address,
      pricePerNight: pricePerNight,
      starRating: starRating,
      averageRating: averageRating,
      images: images, // ảnh đại diện
    );
  }
}