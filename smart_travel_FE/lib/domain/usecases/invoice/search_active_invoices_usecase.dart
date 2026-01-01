import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';

class SearchActiveInvoicesUseCase {
  final InvoiceRepository repository;

  SearchActiveInvoicesUseCase(this.repository);

  Future<List<Invoice>> call({required String keyword}) async {
    return await repository.searchActiveInvoices(keyword: keyword);
  }
}