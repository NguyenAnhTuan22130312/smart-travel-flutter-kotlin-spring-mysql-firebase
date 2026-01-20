class AIDestinationResponse {
  final int id;
  final String name;
  final String category; // Backend trả về 'type' hoặc 'category'
  final String address;
  final double averageRating;
  final int reviewCount;
  final String? imageUrl;
  final String? provinceName;
  final double? price; // <--- THÊM CÁI NÀY

  AIDestinationResponse({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.averageRating,
    required this.reviewCount,
    this.imageUrl,
    this.provinceName,
    this.price,
  });

  factory AIDestinationResponse.fromJson(Map<String, dynamic> json) {
    return AIDestinationResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Chưa có tên",
      // Backend DTO trả về "type" (HOTEL/TOUR), map vào category
      category: json['type'] ?? json['category'] ?? "Địa điểm",
      address: json['address'] ?? "",
      // Backend DTO trả về "rating", map vào averageRating
      averageRating: (json['rating'] ?? json['averageRating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl'],
      provinceName: json['provinceName'], // Có thể null
      price: (json['price'] ?? 0.0).toDouble(), // <--- Map giá tiền
    );
  }
}