class AdminInvoiceDetail {
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

  const AdminInvoiceDetail({
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
}