import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

abstract class HotelRepository {
  /// Lấy danh sách khách sạn theo filter
  Future<Either<Failure, List<Hotel>>> getHotels({
    int? destinationId,
    String? keyword,
    int? minStars,
    int? maxStars,
    double? minPrice,
    double? maxPrice,
    String? city,
    int page = 0,
    int size = 10,
  });

  /// Lấy chi tiết khách sạn + danh sách phòng trống
  Future<Either<Failure, Hotel>> getHotelDetail({
    required int hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
  });
}
