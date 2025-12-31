import 'dart:convert';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/hotel_page.dart';

class HotelsPageModel {
  final List<HotelListItemResponseModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool last;

  HotelsPageModel({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  factory HotelsPageModel.fromJson(Map<String, dynamic> json) {
    return HotelsPageModel(
      content: (json['content'] as List? ?? [])
          .map((e) => HotelListItemResponseModel.fromJson(e))
          .toList(),
      pageNumber: json['pageable']?['pageNumber'] ?? 0,
      pageSize: json['pageable']?['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      totalElements: json['totalElements'] ?? 0,
      last: json['last'] ?? true,
    );
  }

  HotelsPage toEntity() {
    return HotelsPage(
      content: content.map((x) => x.toEntity()).toList(),
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalPages: totalPages,
      totalElements: totalElements,
      last: last,
    );
  }
}

// Model từng phần tử (Item) - ĐÃ BỔ SUNG ĐẦY ĐỦ TRƯỜNG
class HotelListItemResponseModel {
  final int id;
  final String name;
  final String? address;
  final String? thumbnail;
  final double? minPrice;
  final int? stars;
  final double? averageRating;
  final int? reviewCount;

  // --- BỔ SUNG CÁC TRƯỜNG MỚI ĐỂ KHỚP VỚI BACKEND ---
  final int? destinationId;
  final String? destinationName;
  final String? phone;
  final String? email;
  final String? description;
  final List<String>? amenities;
  final int? totalRooms;
  final int? availableRooms;
  final double? latitude;
  final double? longitude;

  HotelListItemResponseModel({
    required this.id,
    required this.name,
    this.address,
    this.thumbnail,
    this.minPrice,
    this.stars,
    this.averageRating,
    this.reviewCount,
    this.destinationId,
    this.destinationName,
    this.phone,
    this.email,
    this.description,
    this.amenities,
    this.totalRooms,
    this.availableRooms,
    this.latitude,
    this.longitude,
  });

  factory HotelListItemResponseModel.fromJson(Map<String, dynamic> json) {
    // Xử lý amenities an toàn (vì backend có thể trả về List lồng String JSON)
    List<String> safeAmenities = [];
    if (json['amenities'] != null) {
      if (json['amenities'] is List) {
        final rawList = json['amenities'] as List;
        if (rawList.isNotEmpty) {
          // Kiểm tra xem có phải là chuỗi JSON bị lồng không (ví dụ: ["[\"Wifi\"]"])
          if (rawList.first is String && rawList.first.toString().trim().startsWith('[')) {
            try {
              safeAmenities = List<String>.from(jsonDecode(rawList.first.toString()));
            } catch (_) {
              safeAmenities = rawList.map((e) => e.toString()).toList();
            }
          } else {
            safeAmenities = rawList.map((e) => e.toString()).toList();
          }
        }
      }
    }
    return HotelListItemResponseModel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'],
      thumbnail: json['thumbnail'],
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      stars: json['stars'] as int?,
      averageRating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['numOfReviews'] as int?,

      // --- MAP CÁC TRƯỜNG MỚI ---
      destinationId: json['destinationId'] as int?,
      destinationName: json['destinationName'],
      phone: json['phone'],
      email: json['email'],
      description: json['description'],
      amenities: safeAmenities,
      totalRooms: json['totalRooms'] as int?,
      availableRooms: json['availableRooms'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Hotel toEntity() {
    return Hotel(
      id: id,
      name: name,
      address: address,
      thumbnail: thumbnail,
      minPrice: minPrice,
      starRating: stars,
      averageRating: averageRating,
      reviewCount: reviewCount,
      destinationId: destinationId,
      destinationName: destinationName,
      phone: phone,
      email: email,
      description: description,
      amenities: amenities,
      totalRooms: totalRooms,
      availableRooms: availableRooms,
      latitude: latitude,
      longitude: longitude,
    );
  }
}