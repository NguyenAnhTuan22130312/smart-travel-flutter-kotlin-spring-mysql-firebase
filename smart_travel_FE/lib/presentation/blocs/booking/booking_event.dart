import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class CreateBookingSubmitted extends BookingEvent {
  final String bookingType; // 'TOUR' hoặc 'HOTEL'
  final int id;             // ID của tour hoặc hotel
  final DateTime startDate;
  final DateTime? endDate;  // Null nếu là Tour (Optional)
  final int numberOfPeople;
  final int numberOfRooms;  // 0 nếu là Tour
  final String? couponCode;
  final int? roomTypeId;

  const CreateBookingSubmitted({
    required this.bookingType,
    required this.id,
    required this.startDate,
    this.endDate,
    required this.numberOfPeople,
    required this.numberOfRooms,
    this.couponCode,
    this.roomTypeId,
  });

  @override
  List<Object?> get props => [bookingType, id, startDate, endDate, numberOfPeople, numberOfRooms,couponCode,roomTypeId];
}