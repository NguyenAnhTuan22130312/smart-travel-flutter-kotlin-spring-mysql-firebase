import '../../repositories/invoice_repository.dart';

class AdminCancelOrderUseCase {
  final InvoiceRepository repository;

  AdminCancelOrderUseCase(this.repository);

  Future<void> call({required int bookingId, required String cancelMessage}) async {
    return await repository.adminCancelOrder(bookingId: bookingId, cancelMessage: cancelMessage);
  }
}