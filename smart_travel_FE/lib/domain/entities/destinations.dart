import 'package:smart_travel/domain/entities/destination_image.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/entities/review.dart';
import 'package:smart_travel/domain/entities/tour.dart';

class DestinationEntity {
  final int id;
  final String name;
  final ProvinceEntity? province;
  final String? description;
  final String? category;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double averageRating;
  final int reviewCount;
  final int viewCount;
  final bool isActive;
  final bool isFeatured;
  final Map<String, dynamic>? openingHours;
  final double? entryFee;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? imageUrl ;
  final String? audioScript;
  final int? experienceReward;

  final List<DestinationImage>? destinationImage;
  final List<Hotel>? hotels;
  final List<Tour>? tours;
  final List<Review>? reviews;


  DestinationEntity({
    required this.id,
    required this.name,
    required this.province,
    this.description,
    this.category,
    this.latitude,
    this.longitude,
    this.address,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.viewCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.openingHours,
    this.entryFee,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.audioScript,
    this.experienceReward,
    this.destinationImage,
    this.hotels,
    this.tours,
    this.reviews,
  });
}