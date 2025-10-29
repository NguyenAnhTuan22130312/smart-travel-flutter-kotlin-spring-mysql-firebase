import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/models/booking/booking_request_model.dart';
import 'package:smart_travel/data/models/booking/booking_response_model.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingResponseModel>> createBooking(
      BookingRequestModel request);
}
