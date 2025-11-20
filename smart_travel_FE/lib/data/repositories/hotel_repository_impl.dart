import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/remote/hotel_data_source.dart';
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
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'));
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
      );

      final entity = responseModal.map((modal) => modal.toEntity()).toList();
      return Right(entity);
    } on ServerException catch (e, stackTrace) {
      _logError('getHotels - ServerException', e, stackTrace);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      _logError('getHotels - NetworkException', e, stackTrace);
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      _logError('getHotels - Unexpected error', e, stackTrace);
      return Left(ServerFailure('Lỗi dữ liệu: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Hotel>> getHotelDetail({
    required int hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'));
    }

    try {
      final responseModal = await hotelDataSource.getHotelDetail(
        hotelId: hotelId,
        checkIn: checkIn,
        checkOut: checkOut,
      );

      developer.log('HotelDetailResponseModel nhận được: $responseModal');

      final entity = responseModal.toEntity();
      developer.log('Convert thành công → Hotel entity: ${entity.name}');

      return Right(entity);
    } on ServerException catch (e, stackTrace) {
      _logError('getHotelDetail - ServerException', e, stackTrace);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e, stackTrace) {
      _logError('getHotelDetail - NetworkException', e, stackTrace);
      return Left(NetworkFailure(e.message));
    } catch (e, stackTrace) {
      _logError('getHotelDetail - LỖI CHÍNH XÁC Ở ĐÂY', e, stackTrace);

      // ← DÒNG QUAN TRỌNG NHẤT: hiện lỗi thật trong UI
      return Left(ServerFailure('Parse error: $e\n\nStack trace:\n$stackTrace'));
    }
  }

  void _logError(String tag, dynamic error, StackTrace stackTrace) {
    developer.log(
      'ERROR → $tag',
      name: 'HotelRepository',
      error: error,
      stackTrace: stackTrace,
    );
  }
}