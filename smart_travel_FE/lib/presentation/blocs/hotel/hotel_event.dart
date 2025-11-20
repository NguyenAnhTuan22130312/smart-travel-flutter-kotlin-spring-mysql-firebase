import 'package:equatable/equatable.dart';

abstract class HotelEvent extends Equatable {
  const HotelEvent();

  @override
  List<Object?> get props => [];
}

// Event gọi API lấy danh sách khách sạn
class LoadHotelsEvent extends HotelEvent {
  final int? destinationId;
  final String? keyword;
  final int? minStars;
  final int? maxStars;
  final double? minPrice;
  final double? maxPrice;
  final String? city;
  final int page;
  final int size;

  const LoadHotelsEvent({
    this.destinationId,
    this.keyword,
    this.minStars,
    this.maxStars,
    this.minPrice,
    this.maxPrice,
    this.city,
    this.page = 0,
    this.size = 10,
  });

  @override
  List<Object?> get props => [
    destinationId,
    keyword,
    minStars,
    maxStars,
    minPrice,
    maxPrice,
    city,
    page,
    size,
  ];
}
