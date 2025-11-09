class Review{
  final int id; // BẮT BUỘC, không null
  final int? userId; // Chỉ lưu ID thay vì User object
  final String? userFullName; // Tên người dùng (lấy từ BE nếu có)
  final int? destinationId;
  final int? hotelId;
  final int? tourId;
  final int? rating;
  final String? comment;
  final int? likesCount;
  final bool? isApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? imageUrls; // Danh sách URL ảnh

  Review({
    required this.id,
    this.userId,
    this.userFullName,
    this.destinationId,
    this.hotelId,
    this.tourId,
    this.rating,
    this.comment,
    this.likesCount,
    this.isApproved,
    this.createdAt,
    this.updatedAt,
    this.imageUrls,
  });
}