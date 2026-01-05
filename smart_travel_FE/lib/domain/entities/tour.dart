class Tour{
  final int id; // BẮT BUỘC, không null
  final String? name;
  final int? destinationId; // Chỉ lưu ID thay vì object
  final String? description;
  final int? durationDays;
  final int? durationNights;
  final double? pricePerPerson;
  final int? maxPeople;
  final int? minPeople;
  final Map<String, dynamic>? included; // JSON → Map
  final Map<String, dynamic>? excluded; // JSON → Map
  final double? averageRating;
  final int? reviewCount;
  final int? bookingCount;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? imageUrls; // Danh sách URL ảnh
  final String? image;

  Tour({
    required this.id,
    this.name,
    this.destinationId,
    this.description,
    this.durationDays,
    this.durationNights,
    this.pricePerPerson,
    this.maxPeople,
    this.minPeople,
    this.included,
    this.excluded,
    this.averageRating,
    this.reviewCount,
    this.bookingCount,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.imageUrls,
    this.image,
  });
}