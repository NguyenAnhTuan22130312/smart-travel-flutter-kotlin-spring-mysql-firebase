import 'package:smart_travel/domain/entities/review.dart';

class ReviewResponse {
  final int id;
  final String userFullName;
  final int rating;
  final String comment;
  final int? likesCount;
  final bool? isApproved;
  final DateTime? createdAt;
  final List<String>? images;

  ReviewResponse({
    required this.id,
    required this.userFullName,
    required this.rating,
    required this.comment,
    this.likesCount,
    this.isApproved,
    this.createdAt,
    this.images,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'] as int,
      userFullName: json['userFullName'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      likesCount: json['likesCount'] as int?,
      isApproved: json['isApproved'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
    );
  }

  Review toEntity() {
    return  Review(
      id: id,
      userFullName: userFullName,
      rating: rating,
      comment: comment,
      likesCount: likesCount,
      isApproved: isApproved,
      createdAt: createdAt,
      imageUrls: images,
    );
  }
}