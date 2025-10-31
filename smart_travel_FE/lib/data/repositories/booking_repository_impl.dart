import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // <-- THÊM IMPORT NÀY
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/remote/booking_data_source.dart';
import 'package:smart_travel/data/models/booking/booking_request_model.dart';
import 'package:smart_travel/data/models/booking/booking_response_model.dart';
import 'package:smart_travel/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingDataSource bookingDataSource;
  final NetworkInfo networkInfo;

  BookingRepositoryImpl({
    required this.bookingDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BookingResponseModel>> createBooking(
      BookingRequestModel request) async {
    if (await networkInfo.isConnected) {
      try {
        // --- BƯỚC 1: CỐ GẮNG GỌI API ---
        final response = await bookingDataSource.createBooking(request);
        print('--- DEBUG (BookingRepo): Gọi API thành công ---');
        return Right(response);
      }
      // --- SỬA LỖI: BẮT DIOEXCEPTION (Lỗi từ Dio/Interceptor) ---
      on DioException catch (e) {
        // 'e.error' là nơi ErrorInterceptor (DioClient) đính kèm ServerException
        if (e.error is ServerException) {
          // Đây là lỗi đã được ErrorInterceptor xử lý (Timeout, 500, 404,...)
          final serverException = e.error as ServerException;

          print('--- LỖI SERVEREXCEPTION (BookingRepo) ---');
          print(serverException.message); // In ra lỗi THẬT

          return Left(ServerFailure(serverException.message));
        } else {
          // Lỗi Dio không xác định (chưa bị Interceptor bắt)
          print('--- LỖI DIO CHƯA XỬ LÝ (BookingRepo) ---');
          print(e.toString());
          return Left(ServerFailure('Lỗi Dio không xác định: ${e.message}'));
        }
      }
      // --- BẮT CÁC LỖI CÒN LẠI (NẾU CÓ) ---
      catch (e) {
        print('--- LỖI CHUNG (BookingRepo) - Lỗi không mong muốn ---');
        print(e.toString());
        return Left(ServerFailure('Lỗi không mong muốn: ${e.toString()}'));
      }
    } else {
      // --- LỖI MẠNG (Không có Wifi/4G) ---
      print('--- LỖI MẠNG (BookingRepo): Không có kết nối mạng ---');
      return Left(NetworkFailure('Không có kết nối mạng'));
    }
  }
}