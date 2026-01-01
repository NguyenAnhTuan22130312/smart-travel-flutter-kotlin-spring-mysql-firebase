import '../../entities/invoice_detail.dart';
import '../../repositories/invoice_repository.dart';

class GetInvoiceDetailUseCase {
  final InvoiceRepository repository;

  GetInvoiceDetailUseCase(this.repository);

  Future<InvoiceDetail> call({required int bookingId}) async {
    return await repository.getInvoiceDetail(bookingId: bookingId);
  }
}