import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // Import DioException
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/domain/repositories/payment_repository.dart';

// (DTOs: PaymentApiRequest và CashApiRequest giữ nguyên)
class PaymentApiRequest {
  final String bookingId;
  final double amount;
  final String paymentMethod;

  PaymentApiRequest({
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'amount': amount,
    'paymentMethod': paymentMethod,
  };
}

class CashApiRequest {
  final String bookingId;
  final double amount;

  CashApiRequest({
    required this.bookingId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'amount': amount,
    'paymentMethod': 'CASH',
  };
}


class PaymentRepositoryImpl implements PaymentRepository {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({required this.dioClient, required this.networkInfo});

  @override
  Future<Either<Failure, String>> createOnlinePayment(PaymentApiRequest request) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await dioClient.post(
          ApiConstants.createOnlinePayment,
          data: request.toJson(),
        );

        // --- DEBUG: IN TOÀN BỘ DỮ LIỆU TRẢ VỀ ---
        print('--- DEBUG: DỮ LIỆU RAW TỪ BACKEND ---');
        print(response.data);
        // ----------------------------------------

        // Backend trả về: { "data": { "paymentUrl": "..." } }
        final String paymentUrl = response.data['data']['paymentUrl'];
        return Right(paymentUrl);

      } on DioException catch (e) {
        // --- SỬA LỖI: Bắt DioException và lấy ServerException từ bên trong ---
        if (e.error is ServerException) {
          final serverFailure = ServerFailure((e.error as ServerException).message);
          print('--- LỖI SERVEREXCEPTION (DioException) ---');
          print(serverFailure.message);
          return Left(serverFailure);
        } else {
          // Lỗi Dio khác
          final serverFailure = ServerFailure(e.message ?? 'Lỗi Dio không xác định');
          print('--- LỖI DIOEXCEPTION CHUNG ---');
          print(serverFailure.message);
          return Left(serverFailure);
        }

      } catch (e) {
        // Bắt lỗi JSON parsing (TypeError, _CastError)
        print('--- LỖI CHUNG (SAI JSON PARSING) ---');
        print(e.toString());
        return Left(ServerFailure('Lỗi phân tích dữ liệu trả về: ${e.toString()}'));
      }
    } else {
      return Left(NetworkFailure('Không có kết nối mạng'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmCashPayment(CashApiRequest request) async {
    // (Tương tự, sửa logic bắt lỗi cho hàm này)
    if (await networkInfo.isConnected) {
      try {
        await dioClient.post(
          ApiConstants.confirmCashPayment,
          data: request.toJson(),
        );
        return Right(null);
      } on DioException catch (e) {
        if (e.error is ServerException) {
          final serverFailure = ServerFailure((e.error as ServerException).message);
          print('--- LỖI SERVEREXCEPTION (DioException - Cash) ---');
          print(serverFailure.message);
          return Left(serverFailure);
        } else {
          final serverFailure = ServerFailure(e.message ?? 'Lỗi Dio không xác định');
          print('--- LỖI DIOEXCEPTION CHUNG (Cash) ---');
          print(serverFailure.message);
          return Left(serverFailure);
        }
      } catch (e) {
        print('--- LỖI CHUNG (SAI JSON PARSING - Cash) ---');
        print(e.toString());
        return Left(ServerFailure('Lỗi phân tích dữ liệu trả về: ${e.toString()}'));
      }
    } else {
      return Left(NetworkFailure('Không có kết nối mạng'));
    }
  }
}

