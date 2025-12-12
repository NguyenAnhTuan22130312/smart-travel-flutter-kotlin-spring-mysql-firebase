import 'package:smart_travel/data/models/destination/destination_image_response_modal.dart';
import 'package:smart_travel/data/models/province/province_response_modal.dart';
import 'package:smart_travel/domain/entities/destinations.dart';

class DestinationFeaturedResponseModel {
  final int id;
  final String name;
  final ProvinceModal? province;
  final String category;
  final String address;
  final double averageRating;
  final int reviewCount;
  final int viewCount;
  final bool isActive;
  final bool isFeatured;
  final double entryFee;
  final List<DestinationImageResponse>? destinationImage;
  const DestinationFeaturedResponseModel({
    required this.id,
    required this.name,
    required this.province,
    required this.category,
    required this.address,
    required this.averageRating,
    required this.reviewCount,
    required this.viewCount,
    required this.isActive,
    required this.isFeatured,
    required this.entryFee,
    required this.destinationImage ,
  });

  /// Hàm chuyển từ JSON sang model
  factory DestinationFeaturedResponseModel.fromJson(Map<String, dynamic> json) {
    return DestinationFeaturedResponseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      province: json['province'] != null
          ? ProvinceModal.formJson(json['province'])
          : null,
      category: json['category'] ?? '',
      address: json['address'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      entryFee: (json['entryFee'] ?? 0).toDouble(),
      destinationImage: json['images'] != null
          ? (json['images'] as List)
          .map((e) => DestinationImageResponse.fromJson(e))
          .toList()
          : [],    );
  }
  DestinationEntity toEntity() {
    return DestinationEntity(
      id: id,
      name: name,
      province: province?.toEntity(),
      category: category,
      address: address,
      averageRating: averageRating,
      reviewCount: reviewCount,
      viewCount: viewCount,
      isActive: isActive,
      isFeatured: isFeatured,
      entryFee: entryFee,
      destinationImage : destinationImage?.map((d) => d.toEntity()).toList(),
    );
  }

}