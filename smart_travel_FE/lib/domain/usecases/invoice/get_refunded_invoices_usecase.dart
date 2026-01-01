import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';

class GetRefundedInvoicesUseCase {
  final InvoiceRepository repository;

  GetRefundedInvoicesUseCase(this.repository);

  Future<List<Invoice>> call() async {
    return await repository.getRefundedInvoices();
  }
}