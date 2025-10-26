import 'package:equatable/equatable.dart';

// DTO (Data Transfer Object) - Dữ liệu mà UI sẽ gửi đi
// Bạn có thể tạo file dto riêng hoặc để tạm ở đây
class CreateBookingRequest extends Equatable {
  final String destinationId;
  final DateTime selectedDate;
  final int numberOfPeople;

  const CreateBookingRequest({
    required this.destinationId,
    required this.selectedDate,
    required this.numberOfPeople,
  });

  @override
  List<Object?> get props => [destinationId, selectedDate, numberOfPeople];
}


abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

// Event khi người dùng nhấn nút "Xác nhận đặt chỗ"
class CreateBookingSubmitted extends BookingEvent {
  final CreateBookingRequest request;
  const CreateBookingSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}