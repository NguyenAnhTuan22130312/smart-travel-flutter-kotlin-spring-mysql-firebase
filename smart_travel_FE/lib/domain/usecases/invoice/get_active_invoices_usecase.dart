import '../../../domain/repositories/invoice_repository.dart';
import '../../entities/invoice.dart';

class GetActiveInvoicesUseCase {
  final InvoiceRepository repository;

  GetActiveInvoicesUseCase(this.repository);

  Future<List<Invoice>> call() async {
    return await repository.getActiveInvoices();
  }
}