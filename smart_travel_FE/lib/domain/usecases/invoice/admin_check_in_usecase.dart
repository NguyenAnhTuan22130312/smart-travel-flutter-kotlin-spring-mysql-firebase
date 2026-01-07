import '../../repositories/invoice_repository.dart';

class AdminCheckInUseCase {
  final InvoiceRepository repository;

  AdminCheckInUseCase(this.repository);

  Future<void> call({required int bookingId, int? numberOfRooms}) async {
    return await repository.adminCheckIn(bookingId: bookingId, numberOfRooms: numberOfRooms);
  }
}