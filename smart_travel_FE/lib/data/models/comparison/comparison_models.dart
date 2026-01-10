import 'package:smart_travel/domain/entities/tour.dart'; // Đảm bảo import đúng entity Tour của bạn
import 'package:smart_travel/domain/entities/hotel.dart'; // Đảm bảo import đúng entity Hotel của bạn

// 1. Generic Response Wrapper
class ComparisonResponse<T> {
  final T item1;
  final T item2;

  ComparisonResponse({required this.item1, required this.item2});

  factory ComparisonResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ComparisonResponse(
      item1: fromJsonT(json['item1']),
      item2: fromJsonT(json['item2']),
    );
  }
}

// 2. Model So sánh Tour
class TourComparisonModel {
  final int id;
  final String name;
  final String? imageUrl;
  final double price;
  final int durationDays;
  final int durationNights;
  final double rating;
  final List<String> included;
  final List<String> excluded;

  TourComparisonModel({
    required this.id, required this.name, this.imageUrl, required this.price,
    required this.durationDays, required this.durationNights, required this.rating,
    required this.included, required this.excluded
  });

  factory TourComparisonModel.fromJson(Map<String, dynamic> json) {
    return TourComparisonModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: (json['price'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? 0,
      durationNights: json['durationNights'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      included: List<String>.from(json['included'] ?? []),
      excluded: List<String>.from(json['excluded'] ?? []),
    );
  }
}

// 3. Model So sánh Hotel
class HotelComparisonModel {
  final int id;
  final String name;
  final String? imageUrl;
  final double pricePerNight;
  final int stars;
  final double rating;
  final int reviewCount;
  final String address;
  final int totalRooms;
  final List<String> amenities;

  HotelComparisonModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.pricePerNight,
    required this.stars,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.totalRooms,
    required this.amenities,
  });

  factory HotelComparisonModel.fromJson(Map<String, dynamic> json) {
    return HotelComparisonModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      imageUrl: json['imageUrl'],
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
      stars: json['stars'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      address: json['address'] ?? "",
      totalRooms: json['totalRooms'] ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }
}