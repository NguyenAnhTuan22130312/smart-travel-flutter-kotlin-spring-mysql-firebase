class BannerUpdateRequest {
  final int id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? description;
  final bool active;

  BannerUpdateRequest({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.description,
    required this.active,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'description': description,
      'active': active,
    };
  }
}