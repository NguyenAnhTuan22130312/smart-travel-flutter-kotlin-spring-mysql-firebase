import 'dart:convert';
import 'package:smart_travel/domain/entities/room_type.dart';

class RoomTypeResponseModel {
  final int id;
  final String name;
  final int? capacity;
  final double? price;
  final int? availableRooms;
  final List<String>? amenities;

  RoomTypeResponseModel({
    required this.id,
    required this.name,
    this.capacity,
    this.price,
    this.availableRooms,
    this.amenities,
  });

  factory RoomTypeResponseModel.fromJson(Map<String, dynamic> json) {
    // Xử lý id an toàn
    final rawId = json['id'];
    final safeId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    // Xử lý amenities (BE đôi khi trả string JSON, đôi khi trả list)
    List<String> parsedAmenities = [];
    if (json['amenities'] != null) {
      if (json['amenities'] is String) {
        // Trường hợp BE trả string JSON
        parsedAmenities = List<String>.from(jsonDecode(json['amenities']));
      } else if (json['amenities'] is List) {
        // Trường hợp BE trả list
        parsedAmenities =
            (json['amenities'] as List).map((e) => e.toString()).toList();
      }
    }

    return RoomTypeResponseModel(
      id: safeId,
      name: json['name']?.toString() ?? 'Không có tên',
      capacity: json['capacity'] is int ? json['capacity'] as int : null,
      price:
          json['price'] != null
              ? double.tryParse(json['price'].toString())
              : null,
      availableRooms: json['availableRooms'] is int ? json['availableRooms'] as int : null,
      amenities: parsedAmenities,
    );
  }

  RoomType toEntity() {
    return RoomType(
      id: id,
      name: name,
      capacity: capacity,
      price: price,
      availableRooms: availableRooms,
      amenities: amenities,
    );
  }
}
