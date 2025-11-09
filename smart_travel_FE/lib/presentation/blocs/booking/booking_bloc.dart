import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_travel/data/models/booking/booking_request_model.dart';
import 'package:smart_travel/domain/usecases/booking/create_booking_usecase.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  // --- SỬA: Inject UseCase thật ---
  final CreateBookingUseCase createBookingUseCase;

  BookingBloc({
    required this.createBookingUseCase, // Sửa constructor
  }) : super(BookingInitial()) {
    on<CreateBookingSubmitted>(_onCreateBookingSubmitted);
  }

  Future<void> _onCreateBookingSubmitted(
      CreateBookingSubmitted event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    // --- SỬA: Ngừng giả lập, gọi API thật ---

    // 1. Tạo Request DTO từ Event
    final request = BookingRequestModel(
      tourId: event.tourId, // Gửi tourId
      startDate: event.startDate,
      numberOfPeople: event.numberOfPeople,
      totalPrice: event.totalPrice,
      couponCode: null,
    );

    // 2. Gọi UseCase thật
    final result = await createBookingUseCase(request);

    // 3. Xử lý kết quả
    result.fold(
          (failure) {
        // Nếu thất bại (Lỗi 404, 500,...)
        emit(BookingFailure(failure.message));
      },
          (response) {
        // Nếu thành công (Backend trả về ID thật)
        emit(BookingCreationSuccess(
          bookingId: response.bookingId, // ID thật từ Backend
          amount: response.amount,     // Amount thật từ Backend
        ));
      },
    );
  }
}