class AIDestinationResponse {
  final int id;
  final String name;
  final String category;
  final String address;
  final double averageRating;
  final int reviewCount;
  final String? imageUrl;
  final String? provinceName;

  AIDestinationResponse({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.averageRating,
    required this.reviewCount,
    this.imageUrl,
    this.provinceName,
  });

  factory AIDestinationResponse.fromJson(Map<String, dynamic> json) {
    return AIDestinationResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Địa điểm chưa đặt tên",
      category: json['category'] ?? "",
      address: json['address'] ?? "",
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl'],
      provinceName: json['provinceName'],
    );
  }
}