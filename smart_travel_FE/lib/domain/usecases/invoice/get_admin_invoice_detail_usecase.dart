import '../../entities/admin_invoice_detail.dart';
import '../../repositories/invoice_repository.dart';

class GetAdminInvoiceDetailUseCase {
  final InvoiceRepository repository;

  GetAdminInvoiceDetailUseCase(this.repository);

  Future<AdminInvoiceDetail> call({required int bookingId}) async {
    return await repository.getAdminInvoiceDetail(bookingId: bookingId);
  }
}