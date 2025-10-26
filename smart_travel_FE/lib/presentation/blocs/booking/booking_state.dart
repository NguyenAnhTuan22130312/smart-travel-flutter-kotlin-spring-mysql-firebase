import 'package:equatable/equatable.dart';
// Bạn sẽ cần tạo Entity này ở bước sau
// import 'package:smart_travel/domain/entities/booking.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu
class BookingInitial extends BookingState {}

// Trạng thái đang xử lý (hiện vòng xoay loading)
class BookingLoading extends BookingState {}

// Trạng thái thành công, trả về một đối tượng Booking
class BookingCreationSuccess extends BookingState {
  // final Booking booking; // Sẽ dùng khi có entity
  // const BookingCreationSuccess(this.booking);

  // Tạm thời chỉ cần báo thành công
  const BookingCreationSuccess();

  @override
  List<Object?> get props => []; // [booking];
}

// Trạng thái thất bại, trả về tin nhắn lỗi
class BookingFailure extends BookingState {
  final String message;
  const BookingFailure(this.message);
  @override
  List<Object?> get props => [message];
}