import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
// Bạn sẽ cần tạo UseCase này ở bước sau
// import 'package:smart_travel/domain/usecases/booking/create_booking_usecase.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  // final CreateBookingUseCase createBookingUseCase; // Sẽ dùng sau

  BookingBloc(
      // {required this.createBookingUseCase} // Sẽ dùng sau
      ) : super(BookingInitial()) {
    on<CreateBookingSubmitted>(_onCreateBookingSubmitted);
  }

  Future<void> _onCreateBookingSubmitted(
      CreateBookingSubmitted event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());

    // TODO: Tạm thời giả lập gọi API
    await Future.delayed(Duration(seconds: 2));

    // Giả lập thành công
    emit(BookingCreationSuccess());

    // Giả lập thất bại (bạn có thể test bằng cách đổi sang dòng này)
    // emit(BookingFailure("Đã có lỗi xảy ra, vui lòng thử lại."));

    /* --- Code thật sẽ như thế này ---
    final result = await createBookingUseCase(event.request);
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (booking) => emit(BookingCreationSuccess(booking)),
    );
    */
  }
}