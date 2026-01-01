class Invoice {
  final int bookingId;
  final String invoiceNumber;
  final String itemName;
  final String startDate;
  final String endDate;
  final int nights;
  final String status;
  final bool reviewed;

  const Invoice({
    required this.bookingId,
    required this.invoiceNumber,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.status,
    required this.reviewed,
  });
}