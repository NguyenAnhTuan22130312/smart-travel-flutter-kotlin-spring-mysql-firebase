import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart'; // Thư viện của bạn
import 'package:smart_travel/data/repositories/payment_repository_impl.dart'; // Import DTOs

abstract class PaymentRepository {
  Future<Either<Failure, String>> createOnlinePayment(PaymentApiRequest request);
  Future<Either<Failure, void>> confirmCashPayment(CashApiRequest request);
}