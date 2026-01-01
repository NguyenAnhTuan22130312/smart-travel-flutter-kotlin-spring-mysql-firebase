import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';

class GetTransactionHistoryUseCase {
  final InvoiceRepository repository;

  GetTransactionHistoryUseCase(this.repository);

  Future<List<Invoice>> call({String? type, String? status}) async {
    return await repository.getTransactionHistory(type: type, status: status);
  }
}