import 'package:smart_travel/data/models/banner/banner_update_request.dart';

class BannerUpdateParams {
  final int id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? description;
  final bool active;

  BannerUpdateParams({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.description,
    required this.active,
  });

  // Chuyển đổi sang Request DTO
  BannerUpdateRequest toRequest() {
    return BannerUpdateRequest(
      id: id,
      title: title,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
      description: description,
      active: active,
    );
  }
}