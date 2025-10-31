import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/repositories/payment_repository_impl.dart';
import 'package:smart_travel/domain/repositories/payment_repository.dart';

class ConfirmCashBookingUseCase {
  final PaymentRepository repository;

  ConfirmCashBookingUseCase(this.repository);

  Future<Either<Failure, void>> call(CashApiRequest request) {
    return repository.confirmCashPayment(request);
  }
}