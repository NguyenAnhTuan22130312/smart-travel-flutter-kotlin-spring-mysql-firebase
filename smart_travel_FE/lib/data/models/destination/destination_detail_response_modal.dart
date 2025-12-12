import 'dart:convert';

import 'package:smart_travel/data/models/destination/destination_image_response_modal.dart';
import 'package:smart_travel/data/models/hotel/hotel_summary_response_modal.dart';
import 'package:smart_travel/data/models/province/province_response_modal.dart';
import 'package:smart_travel/data/models/review/review_response_modal.dart';
import 'package:smart_travel/data/models/tour/tour_summary_response_modal.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

class DestinationDetailResponse {

  final int id;
  final String name;
  final String description;
  final String category;
  final String address;
  final double latitude;
  final double longitude;

  final ProvinceModal? province;

  final double? averageRating;
  final int? reviewCount;
  final int? viewCount;

  final double? entryFee;
  final String? openingHours;

  final bool? isActive;
  final bool? isFeatured;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<DestinationImageResponse>? destinationImage;
  final List<HotelSummaryResponse>? hotels;
  final List<TourSummaryResponse>? tours;
  final List<ReviewResponse>? reviews;

  DestinationDetailResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.province,
    this.averageRating,
    this.reviewCount,
    this.viewCount,
    this.entryFee,
    this.openingHours,
    this.isActive,
    this.isFeatured,
    this.createdAt,
    this.updatedAt,
    this.destinationImage,
    this.hotels,
    this.tours,
    this.reviews,
  });

  factory DestinationDetailResponse.fromJson(Map<String, dynamic> json) {
    return DestinationDetailResponse(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      province: json['province'] != null
          ? ProvinceModal.formJson(json['province'])
          : null,
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : null,
      reviewCount: json['reviewCount'],
      viewCount: json['viewCount'],
      entryFee: json['entryFee'] != null
          ? (json['entryFee'] as num).toDouble()
          : null,
      openingHours: json['openingHours'],
      isActive: json['isActive'],
      isFeatured: json['isFeatured'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      destinationImage: json['images'] != null
          ? (json['images'] as List)
          .map((e) => DestinationImageResponse.fromJson(e))
          .toList()
          : [],

      hotels: json['hotels'] != null
          ? (json['hotels'] as List)
          .map((e) => HotelSummaryResponse.fromJson(e))
          .toList()
          : [],
      tours: json['tours'] != null
          ? (json['tours'] as List)
          .map((e) => TourSummaryResponse.fromJson(e))
          .toList()
          : [],
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
          .map((e) => ReviewResponse.fromJson(e))
          .toList()
          : [],
    );
  }

  DestinationEntity toEntity() {
    return DestinationEntity(
      id: id,
      name: name,
      province: province?.toEntity(),
      description: description,
      category: category,
      latitude: latitude,
      longitude: longitude,
      address: address,
      averageRating: averageRating ?? 0.0,
      reviewCount: reviewCount ?? 0,
      viewCount: viewCount ?? 0,
      isActive: isActive ?? true,
      isFeatured: isFeatured ?? false,
      openingHours: openingHours != null
          ? _parseOpeningHours(openingHours!)
          : null,
      entryFee: entryFee,
      createdAt: createdAt,
      updatedAt: updatedAt,
      destinationImage : destinationImage?.map((d) => d.toEntity()).toList(),
      hotels: hotels?.map((h) => h.toEntity()).toList(),
      tours: tours?.map((t) => t.toEntity()).toList(),
      reviews: reviews?.map((r) => r.toEntity()).toList(),
    );
  }
  // Helper: Parse chuỗi openingHours → Map
  Map<String, dynamic> _parseOpeningHours(String hours) {
    try {
      // BE trả về JSON string: '{"Mon": "08:00-17:00", "Tue": "08:00-17:00"}'
      final decoded = json.decode(hours);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return {};
  }

}
