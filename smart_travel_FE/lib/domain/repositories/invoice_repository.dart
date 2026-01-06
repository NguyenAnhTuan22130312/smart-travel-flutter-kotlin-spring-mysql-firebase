import '../entities/admin_invoice.dart';
import '../entities/admin_invoice_detail.dart';
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
  Future<List<AdminInvoice>> getAdminInvoices({
    String? status,
    String? invoiceNumber,
  });
  Future<AdminInvoiceDetail> getAdminInvoiceDetail({required int bookingId});

  Future<void> adminCheckIn({required int bookingId, int? numberOfRooms});
  Future<void> adminCheckOut({required int bookingId});
  Future<void> adminApproveRefund({required int bookingId});
  Future<void> adminCancelOrder({required int bookingId, required String cancelMessage});
}