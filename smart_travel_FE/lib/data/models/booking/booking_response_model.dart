class BookingResponseModel {
  final String bookingId;
  final double amount;
  final String message;

  BookingResponseModel({
    required this.bookingId,
    required this.amount,
    required this.message,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingResponseModel(
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toDouble(),
      message: json['message'] as String,
    );
  }
}
