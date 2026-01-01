class InvoiceDetail {
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

  InvoiceDetail({
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
}