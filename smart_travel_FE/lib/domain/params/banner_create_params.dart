import 'package:smart_travel/data/models/banner/banner_create_request.dart';

class BannerCreateParams {
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? description;

  BannerCreateParams({
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.description,
  });

  // Chuyển đổi từ Params sang Request DTO để gửi lên Server
  BannerCreateRequest toRequest() {
    return BannerCreateRequest(
      title: title,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
      description: description,
    );
  }
}