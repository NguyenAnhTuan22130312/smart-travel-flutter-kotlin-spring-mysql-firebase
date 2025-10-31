import 'package:intl/intl.dart';


class BookingRequestModel {
  // --- SỬA THEO Ý BẠN: Gửi tourId ---
  final String tourId;
  // ---------------------------------
  final DateTime startDate;
  final int numberOfPeople;
  final double totalPrice;
  final String? couponCode;

  BookingRequestModel({
    required this.tourId,
    required this.startDate,
    required this.numberOfPeople,
    required this.totalPrice,
    this.couponCode,
  });

  Map<String, dynamic> toJson() {
    return {
      // --- SỬA THEO Ý BẠN: Gửi tourId ---
      'tourId': int.tryParse(tourId) ?? 0, // Gửi Long
      // ---------------------------------
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'numberOfPeople': numberOfPeople,
      'totalPrice': totalPrice,
      'couponCode': couponCode,
    };
  }
}