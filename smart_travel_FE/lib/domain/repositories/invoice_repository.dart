import '../entities/invoice.dart';
import '../entities/invoice_detail.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getActiveInvoices();
  Future<List<Invoice>> getTransactionHistory({String? type, String? status});
  Future<List<Invoice>> getRefundedInvoices();
  Future<List<Invoice>> getReviewableInvoices();
  Future<List<Invoice>> searchActiveInvoices({required String keyword});
  Future<void> cancelBooking({required int bookingId, required String reason});
  Future<InvoiceDetail> getInvoiceDetail({required int bookingId});
}