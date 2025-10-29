import 'package:equatable/equatable.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingCreationSuccess extends BookingState {
  // Backend trả về (ID thật, Amount thật)
  final String bookingId;
  final double amount;

  const BookingCreationSuccess({
    required this.bookingId,
    required this.amount,
  });

  @override
  List<Object> get props => [bookingId, amount];
}

class BookingFailure extends BookingState {
  final String message;
  const BookingFailure(this.message);
  @override
  List<Object> get props => [message];
}
