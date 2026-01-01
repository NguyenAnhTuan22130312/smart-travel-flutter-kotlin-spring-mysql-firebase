import 'package:smart_travel/domain/entities/invoice_detail.dart';

class InvoiceDetailModel {
  final int bookingId;
  final String invoiceNumber;
  final String bookingType;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int? hotelId;
  final int? tourId;
  final String serviceName;
  final String? roomTypeName;
  final List<String> roomAmenities;
  final String thumbnailUrl;
  final String startDate;
  final String endDate;
  final int nights;
  final int numberOfPeople;
  final String? specialRequests;
  final double totalPrice;
  final double discountAmount;
  final double finalPrice;
  final String paymentStatus;
  final double taxAmount;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final bool reviewed;

  InvoiceDetailModel({
    required this.bookingId,
    required this.invoiceNumber,
    required this.bookingType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.hotelId,
    this.tourId,
    required this.serviceName,
    this.roomTypeName,
    required this.roomAmenities,
    required this.thumbnailUrl,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.numberOfPeople,
    this.specialRequests,
    required this.totalPrice,
    required this.discountAmount,
    required this.finalPrice,
    required this.paymentStatus,
    required this.taxAmount,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.reviewed,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailModel(
      bookingId: json['bookingId'] as int,
      invoiceNumber: json['invoiceNumber'] as String,
      bookingType: json['bookingType'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      hotelId: json['hotelId'] as int?,
      tourId: json['tourId'] as int?,
      serviceName: json['serviceName'] as String,
      roomTypeName: json['roomTypeName'] as String?,
      roomAmenities: List<String>.from(json['roomAmenities'] ?? []),
      thumbnailUrl: json['thumbnailUrl'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      nights: json['nights'] as int,
      numberOfPeople: json['numberOfPeople'] as int,
      specialRequests: json['specialRequests'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      taxAmount: (json['taxAmount'] as num).toDouble(),
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerEmail: json['customerEmail'] as String,
      reviewed: json['reviewed'] as bool? ?? false,
    );
  }

  InvoiceDetail toEntity() {
    return InvoiceDetail(
      bookingId: bookingId,
      invoiceNumber: invoiceNumber,
      bookingType: bookingType,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      hotelId: hotelId,
      tourId: tourId,
      serviceName: serviceName,
      roomTypeName: roomTypeName,
      roomAmenities: roomAmenities,
      thumbnailUrl: thumbnailUrl,
      startDate: startDate,
      endDate: endDate,
      nights: nights,
      numberOfPeople: numberOfPeople,
      specialRequests: specialRequests,
      totalPrice: totalPrice,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
      paymentStatus: paymentStatus,
      taxAmount: taxAmount,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      reviewed: reviewed,
    );
  }
}