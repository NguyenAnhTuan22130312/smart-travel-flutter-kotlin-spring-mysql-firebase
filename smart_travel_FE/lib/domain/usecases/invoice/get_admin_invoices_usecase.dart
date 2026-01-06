import '../../entities/admin_invoice.dart';
import '../../repositories/invoice_repository.dart';

class GetAdminInvoicesUseCase {
  final InvoiceRepository repository;

  GetAdminInvoicesUseCase(this.repository);

  Future<List<AdminInvoice>> call({
    String? status,
    String? invoiceNumber,
  }) async {
    return await repository.getAdminInvoices(
      status: status,
      invoiceNumber: invoiceNumber,
    );
  }
}