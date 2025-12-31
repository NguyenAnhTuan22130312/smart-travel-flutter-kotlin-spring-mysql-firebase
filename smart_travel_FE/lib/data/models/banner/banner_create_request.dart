class BannerCreateRequest {
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? description;

  BannerCreateRequest({
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.description,
  });

  // Chuyển đổi đối tượng sang Map để encode sang JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'description': description,
    };
  }
}