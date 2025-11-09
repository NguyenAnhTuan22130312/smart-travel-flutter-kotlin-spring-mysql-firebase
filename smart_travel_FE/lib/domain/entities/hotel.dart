class Hotel{
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
  final Map<String, dynamic>? amenities; // JSON → Map
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? imageUrls; // Danh sách ảnh
  final String? thumbnail; // Ảnh chính (tính từ BE)
  final double? minPrice; // Giá rẻ nhất (tính từ BE)
  final String? images;

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
  });
}