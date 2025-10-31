class DestinationEntity {
  final int? id;
  final String name;
  final String province;
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
  final String imageUrl ;


  DestinationEntity({
    this.id,
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
    required this.imageUrl
  });
}