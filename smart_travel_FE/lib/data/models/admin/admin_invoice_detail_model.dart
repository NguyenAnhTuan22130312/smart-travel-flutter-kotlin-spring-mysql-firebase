import 'package:smart_travel/domain/entities/admin_invoice_detail.dart';

class AdminInvoiceDetailModel {
  final int bookingId;
  final String invoiceNumber;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int? hotelId;
  final int? tourId;
  final String serviceName;
  final String? roomTypeName;
  final String startDate;
  final String endDate;
  final int numberOfPeople;
  final int? numberOfRooms;
  final String? specialRequests;
  final String? cancellationReason;
  final double totalPrice;
  final double discountAmount;
  final double finalPrice;
  final String paymentStatus;
  final double taxAmount;
  final String customerName;
  final String customerPhone;
  final String customerEmail;

  AdminInvoiceDetailModel({
    required this.bookingId,
    required this.invoiceNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.hotelId,
    this.tourId,
    required this.serviceName,
    this.roomTypeName,
    required this.startDate,
    required this.endDate,
    required this.numberOfPeople,
    this.numberOfRooms,
    this.specialRequests,
    this.cancellationReason,
    required this.totalPrice,
    required this.discountAmount,
    required this.finalPrice,
    required this.paymentStatus,
    required this.taxAmount,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
  });

  factory AdminInvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return AdminInvoiceDetailModel(
      bookingId: json['bookingId'] as int,
      invoiceNumber: (json['invoiceNumber'] as String?) ?? "Không có mã đơn",
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      hotelId: json['hotelId'] as int?,
      tourId: json['tourId'] as int?,
      serviceName: json['serviceName'] as String,
      roomTypeName: json['roomTypeName'] as String?,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      numberOfPeople: json['numberOfPeople'] as int,
      numberOfRooms: json['numberOfRooms'] as int?,
      specialRequests: json['specialRequests'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      taxAmount: (json['taxAmount'] as num).toDouble(),
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerEmail: json['customerEmail'] as String,
    );
  }

  AdminInvoiceDetail toEntity() {
    return AdminInvoiceDetail(
      bookingId: bookingId,
      invoiceNumber: invoiceNumber,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      hotelId: hotelId,
      tourId: tourId,
      serviceName: serviceName,
      roomTypeName: roomTypeName,
      startDate: startDate,
      endDate: endDate,
      numberOfPeople: numberOfPeople,
      numberOfRooms: numberOfRooms,
      specialRequests: specialRequests,
      cancellationReason: cancellationReason,
      totalPrice: totalPrice,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
      paymentStatus: paymentStatus,
      taxAmount: taxAmount,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
    );
  }
}