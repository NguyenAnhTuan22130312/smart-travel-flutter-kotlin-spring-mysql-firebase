import 'package:smart_travel/domain/entities/reviewhtd.dart';

class ReviewHtdModel {
  final int id;
  final String userFullName;
  final int rating;
  final String? comment;
  final int likesCount;
  final bool isApproved;
  final String createdAt;
  final List<String> images;

  ReviewHtdModel({
    required this.id,
    required this.userFullName,
    required this.rating,
    this.comment,
    required this.likesCount,
    required this.isApproved,
    required this.createdAt,
    required this.images,
  });

  factory ReviewHtdModel.fromJson(Map<String, dynamic> json) {
    return ReviewHtdModel(
      id: json['id'] as int,
      userFullName: json['userFullName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      likesCount: json['likesCount'] as int,
      isApproved: json['isApproved'] as bool,
      createdAt: json['createdAt'] as String,
      images: List<String>.from(json['images'] ?? []),
    );
  }

  ReviewHtd toEntity() {
    return ReviewHtd(
      id: id,
      userFullName: userFullName,
      rating: rating,
      comment: comment,
      likesCount: likesCount,
      isApproved: isApproved,
      createdAt: createdAt,
      images: images,
    );
  }
}