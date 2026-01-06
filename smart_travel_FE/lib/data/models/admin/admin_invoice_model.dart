import 'package:smart_travel/domain/entities/admin_invoice.dart';

class AdminInvoiceModel {
  final int bookingId;
  final String invoiceNumber;
  final String itemName;
  final String startDate;
  final String endDate;
  final String status;

  AdminInvoiceModel({
    required this.bookingId,
    required this.invoiceNumber,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory AdminInvoiceModel.fromJson(Map<String, dynamic> json) {
    return AdminInvoiceModel(
      bookingId: json['bookingId'] as int? ?? 0,
      invoiceNumber: (json['invoiceNumber'] as String?) ?? "Không có mã đơn",
      itemName: (json['itemName'] as String?) ?? "Không có tên dịch vụ",
      startDate: (json['startDate'] as String?) ?? "Không rõ",
      endDate: (json['endDate'] as String?) ?? "Không rõ",
      status: (json['status'] as String?) ?? "UNKNOWN",
    );
  }

  AdminInvoice toEntity() {
    return AdminInvoice(
      bookingId: bookingId,
      invoiceNumber: invoiceNumber,
      itemName: itemName,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
  }
}