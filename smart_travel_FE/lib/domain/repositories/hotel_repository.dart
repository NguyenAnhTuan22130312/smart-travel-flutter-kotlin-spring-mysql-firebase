import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/models/hotel/hotel_create_request.dart';
import 'package:smart_travel/domain/entities/hotel_page.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

abstract class HotelRepository {
  /// Lấy danh sách khách sạn theo filter
  Future<Either<Failure, HotelsPage>> getHotels({
    int? destinationId,
    String? keyword,
    int? minStars,
    int? maxStars,
    double? minPrice,
    double? maxPrice,
    String? city,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDir,
  });

  /// Lấy chi tiết khách sạn + danh sách phòng trống
  Future<Either<Failure, Hotel>> getHotelDetail({
    required int hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
  });

  //Tạo mới khách sạn
  Future<Either<Failure, Hotel>> createHotel(HotelCreateRequest request);

  // Cập nhật thông tin khách sạn
  Future<Either<Failure, Hotel>> updateHotel(
    int id,
    HotelCreateRequest request,
  );

  // Xóa khách sạn
  Future<Either<Failure, String>> deleteHotel(int id);

  /// Upload danh sách ảnh cho một khách sạn
  Future<Either<Failure, String>> uploadHotelImages(
    int hotelId,
    List<File> images,
  );
}
