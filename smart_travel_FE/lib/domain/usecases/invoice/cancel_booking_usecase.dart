import '../../repositories/invoice_repository.dart';

class CancelBookingUseCase {
  final InvoiceRepository repository;

  CancelBookingUseCase(this.repository);

  Future<void> call({required int bookingId, required String reason}) async {
    return await repository.cancelBooking(bookingId: bookingId, reason: reason);
  }
}