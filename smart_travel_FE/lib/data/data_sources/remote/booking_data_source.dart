import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/data/models/booking/booking_request_model.dart';
import 'package:smart_travel/data/models/booking/booking_response_model.dart';

abstract class BookingDataSource {
  Future<BookingResponseModel> createBooking(BookingRequestModel request);
}

class BookingDataSourceImpl implements BookingDataSource {
  final DioClient client;

  BookingDataSourceImpl({required this.client});

  @override
  Future<BookingResponseModel> createBooking(BookingRequestModel request) async {
    final response = await client.post(
      ApiConstants.createBooking, // Gọi API thật '/bookings'
      data: request.toJson(),
    );
    // Parse JSON trả về (data chứa BookingResponse)
    return BookingResponseModel.fromJson(response.data);
  }
}
