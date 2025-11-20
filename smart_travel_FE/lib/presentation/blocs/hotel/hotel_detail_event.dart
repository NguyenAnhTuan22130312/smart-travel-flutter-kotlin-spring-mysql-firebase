import 'package:equatable/equatable.dart';

abstract class HotelDetailEvent extends Equatable {
  const HotelDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event gọi API lấy chi tiết khách sạn
class GetHotelDetailEvent extends HotelDetailEvent {
  final int hotelId;
  final DateTime checkIn;
  final DateTime checkOut;

  const GetHotelDetailEvent({
    required this.hotelId,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  List<Object?> get props => [hotelId, checkIn, checkOut];
}
