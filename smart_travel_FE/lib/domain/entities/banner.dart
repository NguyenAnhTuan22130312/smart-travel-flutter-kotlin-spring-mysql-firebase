class BannerEntity {
  final int id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? description;
  final bool active;

  BannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.description,
    required this.active,
  });
}