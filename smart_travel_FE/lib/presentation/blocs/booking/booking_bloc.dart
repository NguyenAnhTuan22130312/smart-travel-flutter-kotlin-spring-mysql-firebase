import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Để format ngày tháng
import 'booking_event.dart';
import 'booking_state.dart';
import 'package:smart_travel/data/models/booking/booking_request_model.dart';
import 'package:smart_travel/domain/usecases/booking/create_booking_usecase.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase createBookingUseCase;

  BookingBloc({required this.createBookingUseCase}) : super(BookingInitial()) {
    on<CreateBookingSubmitted>(_onCreateBookingSubmitted);
  }

  Future<void> _onCreateBookingSubmitted(
      CreateBookingSubmitted event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    // Format ngày tháng chuẩn yyyy-MM-dd cho Backend
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Tạo Request Model dựa trên Type
    final request = BookingRequestModel(
      bookingType: event.bookingType,
      // Nếu là TOUR thì set tourId, hotelId = null
      tourId: event.bookingType == 'TOUR' ? event.id : null,
      // Nếu là HOTEL thì set hotelId, tourId = null
      hotelId: event.bookingType == 'HOTEL' ? event.id : null,

      startDate: dateFormat.format(event.startDate),
      endDate: event.endDate != null ? dateFormat.format(event.endDate!) : null,

      numberOfPeople: event.numberOfPeople,
      numberOfRooms: event.numberOfRooms,
        couponCode: event.couponCode,
      roomTypeId: event.roomTypeId,
    );

    final result = await createBookingUseCase(request);

    result.fold(
          (failure) => emit(BookingFailure(failure.message)),
          (response) => emit(BookingCreationSuccess(
        bookingId: response.bookingId,
        amount: response.amount,
      )),
    );
  }
}