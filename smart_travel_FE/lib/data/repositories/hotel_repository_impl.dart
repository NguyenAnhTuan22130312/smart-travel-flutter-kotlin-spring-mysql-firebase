import 'dart:developer' as developer;
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/remote/hotel_data_source.dart';
import 'package:smart_travel/data/models/hotel/hotel_create_request.dart';
import 'package:smart_travel/domain/entities/hotel_page.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';

class HotelRepositoryImpl implements HotelRepository {
  final HotelDataSource hotelDataSource;
  final NetworkInfo networkInfo;

  HotelRepositoryImpl({
    required this.hotelDataSource,
    required this.networkInfo,
  });

  @override
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }
    try {
      final responseModal = await hotelDataSource.getHotels(
        destinationId: destinationId,
        keyword: keyword,
        minStars: minStars,
        maxStars: maxStars,
        minPrice: minPrice,
        maxPrice: maxPrice,
        city: city,
        page: page,
        size: size,
        sortBy: sortBy,
        sortDir: sortDir,
      );
      return Right(responseModal.toEntity());
    } on ServerException catch (e, s) {
      _logError('getHotels', e, s);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, s) {
      _logError('getHotels', e, s);
      return Left(NetworkFailure(e.message));
    } catch (e, s) {
      _logError('getHotels', e, s);
      return Left(ServerFailure(e.toString()));
    }
  }

  // 2. GET HOTEL DETAIL
  @override
  Future<Either<Failure, Hotel>> getHotelDetail({
    required int hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }
    try {
      final responseModal = await hotelDataSource.getHotelDetail(
        hotelId: hotelId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
      return Right(responseModal.toEntity());
    } on ServerException catch (e, s) {
      _logError('getHotelDetail', e, s);
      return Left(ServerFailure(e.message));
    } catch (e, s) {
      _logError('getHotelDetail', e, s);
      return Left(ServerFailure(e.toString()));
    }
  }

  // 3. CREATE HOTEL (Mới)
  @override
  Future<Either<Failure, Hotel>> createHotel(HotelCreateRequest request) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }

    try {
      // Gọi DataSource
      final responseModel = await hotelDataSource.createHotel(request);

      // Convert Model -> Entity
      return Right(responseModel.toEntity());
    } on ServerException catch (e, s) {
      _logError('createHotel', e, s);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, s) {
      _logError('createHotel', e, s);
      return Left(NetworkFailure(e.message));
    } catch (e, s) {
      _logError('createHotel', e, s);
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  // 4. UPDATE HOTEL (Mới)
  @override
  Future<Either<Failure, Hotel>> updateHotel(
    int id,
    HotelCreateRequest request,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }

    try {
      final responseModel = await hotelDataSource.updateHotel(id, request);
      return Right(responseModel.toEntity());
    } on ServerException catch (e, s) {
      _logError('updateHotel', e, s);
      return Left(ServerFailure(e.message));
    } catch (e, s) {
      _logError('updateHotel', e, s);
      return Left(ServerFailure(e.toString()));
    }
  }

  // 5. DELETE HOTEL (Mới)
  @override
  Future<Either<Failure, String>> deleteHotel(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }

    try {
      final message = await hotelDataSource.deleteHotel(id);
      return Right(message);
    } on ServerException catch (e, s) {
      _logError('deleteHotel', e, s);
      return Left(ServerFailure(e.message));
    } catch (e, s) {
      _logError('deleteHotel', e, s);
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper Log
  void _logError(String tag, dynamic error, StackTrace stackTrace) {
    developer.log(
      'ERROR → $tag',
      name: 'HotelRepository',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 6. UPLOAD IMAGES
  @override
  Future<Either<Failure, String>> uploadHotelImages(
    int hotelId,
    List<File> images,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }
    try {
      final result = await hotelDataSource.uploadImages(hotelId, images);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
