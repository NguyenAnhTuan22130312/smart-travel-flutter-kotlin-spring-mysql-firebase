import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

// Trạng thái khởi tạo
class HotelInitial extends HotelState {}

// Trạng thái đang tải (Dùng chung cho cả lần đầu và khi chuyển trang)
class HotelLoading extends HotelState {}

// Trạng thái load thành công
class HotelLoaded extends HotelState {
  final List<Hotel> hotels;
  final int currentPage; // Để biết đang ở trang nào (để tô màu nút)
  final int totalPages;  // Để biết có bao nhiêu nút (để vẽ list 1, 2, 3...)

  const HotelLoaded({
    required this.hotels,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [hotels, currentPage, totalPages];
}

// Trạng thái lỗi
class HotelError extends HotelState {
  final String message;

  const HotelError(this.message);

  @override
  List<Object?> get props => [message];
}