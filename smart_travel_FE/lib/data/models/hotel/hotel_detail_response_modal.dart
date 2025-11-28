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
    this.destinationName,
    this.provinceName,
    this.rooms,
    this.latitude,
    this.longitude,
  });

  factory HotelDetailResponseModel.fromJson(Map<String, dynamic> json) {
    // Xử lý ID an toàn vì đôi khi BE trả string
    final rawId = json['id'];
    final safeId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    // Xử lý rating an toàn
    double? safeRating;
    if (json['rating'] != null) {
      safeRating = double.tryParse(json['rating'].toString());
    }

    // Xử lý images
    List<String>? safeImages;
    if (json['images'] != null) {
      if (json['images'] is List) {
        safeImages = json['images'].map<String>((e) => e.toString()).toList();
      } else if (json['images'] is String) {
        // trường hợp BE trả chuỗi JSON
        safeImages = List<String>.from(jsonDecode(json['images']));
      }
    }

    // Xử lý rooms
    List<RoomTypeResponseModel>? safeRooms;
    if (json['rooms'] != null) {
      if (json['rooms'] is List) {
        safeRooms =
            json['rooms']
                .where((e) => e != null)
                .map<RoomTypeResponseModel>(
                  (e) => RoomTypeResponseModel.fromJson(e),
                )
                .toList();
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
      images: safeImages,
      destinationName: json['destinationName']?.toString(),
      provinceName: json['provinceName']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,

      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      rooms: safeRooms,
    );
  }

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
      destinationName: destinationName,
      provinceName: provinceName,
      latitude: latitude,
      longitude: longitude,
      rooms: rooms?.map((roomModel) => roomModel.toEntity()).toList(),
    );
  }
}
