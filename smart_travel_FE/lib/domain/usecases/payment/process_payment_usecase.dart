import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/repositories/payment_repository_impl.dart';
import 'package:smart_travel/domain/repositories/payment_repository.dart';

class ProcessPaymentUseCase {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  Future<Either<Failure, String>> call(PaymentApiRequest request) {
    return repository.createOnlinePayment(request);
  }
}