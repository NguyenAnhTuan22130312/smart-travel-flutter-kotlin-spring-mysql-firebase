import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

// trạng thái khởi tạo
class HotelInitial extends HotelState {}

// trạng thái đang load
class HotelLoading extends HotelState {}

// trạng thái load thành công
class HotelLoaded extends HotelState {
  final List<Hotel> hotels;
  final bool isLimited;

  const HotelLoaded(this.hotels, {this.isLimited = false});

  @override
  List<Object?> get props => [hotels, isLimited];
}

// trạng thái lỗi
class HotelError extends HotelState {
  final String message;

  const HotelError(this.message);

  @override
  List<Object?> get props => [message];
}
