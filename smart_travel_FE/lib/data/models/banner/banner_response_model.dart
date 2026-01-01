
import 'package:smart_travel/domain/entities/banner.dart';

class BannerResponseModel {
  final int? id;
  final String? title;
  final String? imageUrl;
  final String? linkUrl;
  final String? description;
  final bool? active;

  BannerResponseModel({
    this.id,
    this.title,
    this.imageUrl,
    this.linkUrl,
    this.description,
    this.active,
  });

  // Hàm Map từ JSON trả về từ API (Spring Boot)
  factory BannerResponseModel.fromJson(Map<String, dynamic> json) {
    return BannerResponseModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      imageUrl: json['imageUrl'] as String?,
      linkUrl: json['linkUrl'] as String?,
      description: json['description'] as String?,
      active: json['active'] as bool?,
    );
  }

  // Hàm chuyển đổi sang Entity để sử dụng trong App
  BannerEntity toEntity() {
    return BannerEntity(
      id: id ?? 0,
      title: title ?? 'Không có tiêu đề',
      imageUrl: imageUrl ?? '',
      linkUrl: linkUrl,
      description: description,
      active: active ?? false,
    );
  }
}