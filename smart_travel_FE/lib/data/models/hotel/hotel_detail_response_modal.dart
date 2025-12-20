import 'dart:convert';
import 'package:smart_travel/data/models/hotel/room_type_response_modal.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

class HotelDetailResponseModel {
  final int id;
  final String? name;
  final String? address;
  final int? stars;
  final double? rating;
  final int? numOfReviews;
  final String? description;
  final String? thumbnail;
  final List<String>? images;
  final String? phone;
  final String? email;
  final int? destinationId;
  final List<String>? amenities;
  final String? destinationName;
  final String? provinceName;
  final double? latitude;
  final double? longitude;
  final List<RoomTypeResponseModel>? rooms;

  HotelDetailResponseModel({
    required this.id,
    this.name,
    this.address,
    this.stars,
    this.rating,
    this.numOfReviews,
    this.description,
    this.thumbnail,
    this.images,
    this.phone,
    this.email,
    this.destinationId,
    this.amenities,
    this.destinationName,
    this.provinceName,
    this.rooms,
    this.latitude,
    this.longitude,
  });

  factory HotelDetailResponseModel.fromJson(Map<String, dynamic> json) {
    // Xử lý ID an toàn
    final rawId = json['id'];
    final safeId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    // Xử lý rating
    double? safeRating;
    if (json['rating'] != null) {
      safeRating = double.tryParse(json['rating'].toString());
    }

    // Xử lý amenities (vì json có thể trả về List hoặc String)
    List<String>? safeAmenities;
    if (json['amenities'] != null) {
      if (json['amenities'] is List) {
        safeAmenities = List<String>.from(json['amenities']);
      } else if (json['amenities'] is String) {
        // Phòng hờ BE trả chuỗi kiểu "wifi, tv"
        safeAmenities = json['amenities'].toString().split(',').map((e)=>e.trim()).toList();
      }
    }

    return HotelDetailResponseModel(
      id: safeId,
      name: json['name']?.toString(),
      address: json['address']?.toString(),
      stars: json['stars'] is int ? json['stars'] as int : null,
      numOfReviews: json['numOfReviews'] is int ? json['numOfReviews'] as int : null,
      rating: safeRating,
      description: json['description']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      destinationId: json['destinationId'] is int ? json['destinationId'] : int.tryParse(json['destinationId'].toString() ?? ""),
      amenities: safeAmenities,
      // ------------------------------------

      images: json['images'] != null
          ? (json['images'] is List ? List<String>.from(json['images']) : [])
          : [],
      destinationName: json['destinationName']?.toString(),
      provinceName: json['provinceName']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      rooms: json['rooms'] != null
          ? (json['rooms'] as List).where((e) => e != null).map((e) => RoomTypeResponseModel.fromJson(e)).toList()
          : null,
    );
  }

  // --- HÀM NÀY ĐẨY DỮ LIỆU VÀO HOTEL ENTITY ---
  Hotel toEntity() {
    return Hotel(
      id: id,
      name: name,
      description: description,
      address: address,
      starRating: stars,
      averageRating: rating,
      reviewCount: numOfReviews,
      imageUrls: images,
      thumbnail: thumbnail,
      phone: phone,
      email: email,
      destinationId: destinationId,
      amenities: amenities,

      destinationName: destinationName,
      provinceName: provinceName,
      latitude: latitude,
      longitude: longitude,
      rooms: rooms?.map((roomModel) => roomModel.toEntity()).toList(),
    );
  }
}