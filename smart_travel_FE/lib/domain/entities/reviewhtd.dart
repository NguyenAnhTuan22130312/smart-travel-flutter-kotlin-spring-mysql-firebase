class ReviewHtd {
  final int id;
  final String userFullName;
  final int rating;
  final String? comment;
  final int likesCount;
  final bool isApproved;
  final String createdAt;
  final List<String> images;

  const ReviewHtd({
    required this.id,
    required this.userFullName,
    required this.rating,
    this.comment,
    required this.likesCount,
    required this.isApproved,
    required this.createdAt,
    required this.images,
  });
}