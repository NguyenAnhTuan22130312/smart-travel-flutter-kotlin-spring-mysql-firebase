import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

class HotelInitial extends HotelState {}

class HotelLoading extends HotelState {}

class HotelLoaded extends HotelState {
  final List<Hotel> hotels;
  final int currentPage;
  final int totalPages;
  final int timestamp;

  HotelLoaded({
    required this.hotels,
    required this.currentPage,
    required this.totalPages,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [hotels, currentPage, totalPages, timestamp];
}

// Trạng thái lỗi
class HotelError extends HotelState {
  final String message;

  const HotelError(this.message);

  @override
  List<Object?> get props => [message];
}

// Xoá khách sạn
class DeleteHotelLoading extends HotelState {}

class DeleteHotelError extends HotelState {
  final String message;
  DeleteHotelError(this.message);

  @override
  List<Object?> get props => [message];
}

class HotelOperationSuccess extends HotelState {
  final String message;
  final int timestamp;

  HotelOperationSuccess(this.message)
    : timestamp = DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object?> get props => [message, timestamp];
}
