import '../../repositories/invoice_repository.dart';

class AdminCheckOutUseCase {
  final InvoiceRepository repository;

  AdminCheckOutUseCase(this.repository);

  Future<void> call({required int bookingId}) async {
    return await repository.adminCheckOut(bookingId: bookingId);
  }
}