import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';

class GetReviewableInvoicesUseCase {
  final InvoiceRepository repository;

  GetReviewableInvoicesUseCase(this.repository);

  Future<List<Invoice>> call() async {
    return await repository.getReviewableInvoices();
  }
}