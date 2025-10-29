import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object> get props => [];
}

class CreateBookingSubmitted extends BookingEvent {
  // --- SỬA THEO Ý BẠN: Gửi tourId ---
  final String tourId;
  // ---------------------------------
  final DateTime startDate;
  final int numberOfPeople;
  final double totalPrice;

  const CreateBookingSubmitted({
    required this.tourId,
    required this.startDate,
    required this.numberOfPeople,
    required this.totalPrice,
  });

  @override
  List<Object> get props => [tourId, startDate, numberOfPeople, totalPrice];
}
