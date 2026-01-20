import 'package:smart_travel/domain/entities/admin_invoice_detail.dart';

class AdminInvoiceDetailModel {
  final int bookingId;
  final String? invoiceNumber; // Cho phép null
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final int? hotelId;
  final int? tourId;
  final String? serviceName;
  final String? roomTypeName;
  final String? startDate;
  final String? endDate;
  final int numberOfPeople;
  final int? numberOfRooms;
  final String? specialRequests;
  final String? cancellationReason;
  final double totalPrice;
  final double discountAmount;
  final double finalPrice;
  final String? paymentStatus;
  final double taxAmount;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;

  AdminInvoiceDetailModel({
    required this.bookingId,
    this.invoiceNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.hotelId,
    this.tourId,
    this.serviceName,
    this.roomTypeName,
    this.startDate,
    this.endDate,
    required this.numberOfPeople,
    this.numberOfRooms,
    this.specialRequests,
    this.cancellationReason,
    required this.totalPrice,
    required this.discountAmount,
    required this.finalPrice,
    this.paymentStatus,
    required this.taxAmount,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
  });

  factory AdminInvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return AdminInvoiceDetailModel(
      // int: Dùng as int? ?? 0
      bookingId: json['bookingId'] as int? ?? 0,

      // String: Dùng as String? (không cần ?? ở đây để giữ nguyên null nếu muốn check ở UI)
      invoiceNumber: json['invoiceNumber'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,

      hotelId: json['hotelId'] as int?,
      tourId: json['tourId'] as int?,

      serviceName: json['serviceName'] as String?,
      roomTypeName: json['roomTypeName'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,

      numberOfPeople: json['numberOfPeople'] as int? ?? 1,
      numberOfRooms: json['numberOfRooms'] as int?,

      specialRequests: json['specialRequests'] as String?,
      cancellationReason: json['cancellationReason'] as String?,

      // Double: Cast an toàn từ num?
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,

      paymentStatus: json['paymentStatus'] as String?,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,

      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerEmail: json['customerEmail'] as String?,
    );
  }

  // Map sang Entity: Tại đây chúng ta điền giá trị mặc định để Entity (Domain Layer) luôn sạch
  AdminInvoiceDetail toEntity() {
    return AdminInvoiceDetail(
      bookingId: bookingId,
      invoiceNumber: invoiceNumber ?? "---", // Nếu null thì hiện ---
      status: status ?? "UNKNOWN",
      createdAt: createdAt ?? "",
      updatedAt: updatedAt ?? "",
      hotelId: hotelId,
      tourId: tourId,
      serviceName: serviceName ?? "Dịch vụ không tên",
      roomTypeName: roomTypeName,
      startDate: startDate ?? "",
      endDate: endDate ?? "",
      numberOfPeople: numberOfPeople,
      numberOfRooms: numberOfRooms,
      specialRequests: specialRequests,
      cancellationReason: cancellationReason,
      totalPrice: totalPrice,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
      paymentStatus: paymentStatus ?? "UNPAID",
      taxAmount: taxAmount,
      customerName: customerName ?? "Khách hàng ẩn danh", // Tránh null name
      customerPhone: customerPhone ?? "",
      customerEmail: customerEmail ?? "",
    );
  }
}