import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

abstract class HotelDetailState extends Equatable {
  const HotelDetailState();

  @override
  List<Object?> get props => [];
}

/// Khởi tạo
class HotelDetailInitial extends HotelDetailState {}

/// Loading
class HotelDetailLoading extends HotelDetailState {}

/// Load thành công
class HotelDetailLoaded extends HotelDetailState {
  final Hotel hotel;

  const HotelDetailLoaded(this.hotel);

  @override
  List<Object?> get props => [hotel];
}

/// Lỗi
class HotelDetailError extends HotelDetailState {
  final String message;

  const HotelDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
