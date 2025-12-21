import 'package:smart_travel/domain/entities/room_type.dart';

class Hotel {
  final int id;
  final String? name;
  final int? destinationId; // Thay vì Destination object
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final int? starRating;
  final double? pricePerNight;
  final double? averageRating;
  final int? reviewCount;
  final int? totalRooms;
  final int? availableRooms;
  final List<String>? amenities;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? imageUrls; // Danh sách ảnh
  final String? thumbnail; // Ảnh chính
  final double? minPrice; // Giá rẻ nhất
  final String? images;
  final String? destinationName;
  final String? provinceName;
  final List<RoomType>? rooms;


  Hotel({
    required this.id,
    this.name,
    this.destinationId,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.starRating,
    this.pricePerNight,
    this.averageRating,
    this.reviewCount,
    this.totalRooms,
    this.availableRooms,
    this.amenities,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.imageUrls,
    this.thumbnail,
    this.minPrice,
    this.images,
    this.destinationName,
    this.provinceName,
    this.rooms,
  });
}
