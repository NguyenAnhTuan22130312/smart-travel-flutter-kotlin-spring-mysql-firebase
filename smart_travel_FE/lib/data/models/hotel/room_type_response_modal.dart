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
    return RoomTypeResponseModel(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'],
      price: (json['price'] != null)
          ? (json['price'] is int ? (json['price'] as int).toDouble() : json['price'])
          : null,
      availableRooms: json['availableRooms'],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
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
