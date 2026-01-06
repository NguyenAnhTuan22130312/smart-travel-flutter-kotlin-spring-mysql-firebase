class AdminInvoice {
  final int bookingId;
  final String invoiceNumber;
  final String itemName;
  final String startDate;
  final String endDate;
  final String status;

  const AdminInvoice({
    required this.bookingId,
    required this.invoiceNumber,
    required this.itemName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}