import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/data/models/hotel/hotel_create_request.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';

class UpdateHotelUseCase extends UseCase<Hotel, UpdateHotelParams> {
  final HotelRepository repository;

  UpdateHotelUseCase(this.repository);

  @override
  Future<Either<Failure, Hotel>> call(UpdateHotelParams params) async {
    return await repository.updateHotel(params.id, params.request);
  }
}

// Class đóng gói tham số cho Update
class UpdateHotelParams extends Equatable {
  final int id;
  final HotelCreateRequest request;

  const UpdateHotelParams({required this.id, required this.request});

  @override
  List<Object?> get props => [id, request];
}