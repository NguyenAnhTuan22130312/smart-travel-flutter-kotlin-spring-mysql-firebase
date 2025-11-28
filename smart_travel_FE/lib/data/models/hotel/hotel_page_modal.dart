import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/hotel_page.dart';

class HotelsPageModel {
  final List<HotelListItemResponseModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool last;

  HotelsPageModel({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  factory HotelsPageModel.fromJson(Map<String, dynamic> json) {
    return HotelsPageModel(
      content: (json['content'] as List? ?? []) // Thêm check null cho an toàn
          .map((e) => HotelListItemResponseModel.fromJson(e))
          .toList(),
      // Dùng toán tử ?. để tránh crash nếu 'pageable' bị null
      pageNumber: json['pageable']?['pageNumber'] ?? 0,
      pageSize: json['pageable']?['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      totalElements: json['totalElements'] ?? 0,
      last: json['last'] ?? true,
    );
  }

  HotelsPage toEntity() {
    return HotelsPage(
      content: content.map((x) => x.toEntity()).toList(),
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalPages: totalPages,
      totalElements: totalElements,
      last: last,
    );
  }
}

// Model từng phần tử (Item)
class HotelListItemResponseModel {
  final int id;
  final String name;
  final String? address;
  final String? thumbnail;
  final double? minPrice;
  final int? stars;
  final double? averageRating;
  final int? reviewCount;

  HotelListItemResponseModel({
    required this.id,
    required this.name,
    this.address,
    this.thumbnail,
    this.minPrice,
    this.stars,
    this.averageRating,
    this.reviewCount,
  });

  factory HotelListItemResponseModel.fromJson(Map<String, dynamic> json) {
    return HotelListItemResponseModel(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'],
      thumbnail: json['thumbnail'],
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      stars: json['stars'] as int?,
      averageRating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['numOfReviews'] as int?,
    );
  }

  Hotel toEntity() {
    return Hotel(
      id: id,
      name: name,
      address: address,
      thumbnail: thumbnail,
      minPrice: minPrice,
      starRating: stars,
      averageRating: averageRating,
      reviewCount: reviewCount,
    );
  }
}