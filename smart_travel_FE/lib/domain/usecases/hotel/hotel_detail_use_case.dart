import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';

class HotelDetailUseCase extends UseCase<Hotel, HotelDetailParams> {
  final HotelRepository hotelRepository;

  HotelDetailUseCase(this.hotelRepository);

  @override
  Future<Either<Failure, Hotel>> call(HotelDetailParams params) {
    return hotelRepository.getHotelDetail(
      hotelId: params.hotelId,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
    );
  }
}

class HotelDetailParams {
  final int hotelId;
  final DateTime checkIn;
  final DateTime checkOut;

  HotelDetailParams({
    required this.hotelId,
    required this.checkIn,
    required this.checkOut,
  });
}
