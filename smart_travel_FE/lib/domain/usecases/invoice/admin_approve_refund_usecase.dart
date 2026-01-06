import '../../repositories/invoice_repository.dart';

class AdminApproveRefundUseCase {
  final InvoiceRepository repository;

  AdminApproveRefundUseCase(this.repository);

  Future<void> call({required int bookingId}) async {
    return await repository.adminApproveRefund(bookingId: bookingId);
  }
}