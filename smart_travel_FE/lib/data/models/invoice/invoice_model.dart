import 'package:smart_travel/domain/entities/invoice.dart';

class InvoiceModel {
  final int bookingId;
  final String invoiceNumber;
  final String itemName;
  final String startDate;
  final String endDate;
  final int nights;
  final String status;
  final bool reviewed;

  InvoiceModel({
    required this.bookingId,
    required this.invoiceNumber,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.status,
    required this.reviewed,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      bookingId: json['bookingId'] as int,
      invoiceNumber: json['invoiceNumber'] as String,
      itemName: json['itemName'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      nights: json['nights'] as int,
      status: json['status'] as String,
      reviewed: json['reviewed'] as bool,
    );
  }

  Invoice toEntity() {
    return Invoice(
      bookingId: bookingId,
      invoiceNumber: invoiceNumber,
      itemName: itemName,
      startDate: startDate,
      endDate: endDate,
      nights: nights,
      status: status,
      reviewed: reviewed,
    );
  }
}