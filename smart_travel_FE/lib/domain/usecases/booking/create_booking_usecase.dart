import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/data/models/booking/booking_request_model.dart';
import 'package:smart_travel/data/models/booking/booking_response_model.dart';
import 'package:smart_travel/domain/repositories/booking_repository.dart';

class CreateBookingUseCase
    implements UseCase<BookingResponseModel, BookingRequestModel> {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  @override
  Future<Either<Failure, BookingResponseModel>> call(
      BookingRequestModel params) async {
    return await repository.createBooking(params);
  }
}
