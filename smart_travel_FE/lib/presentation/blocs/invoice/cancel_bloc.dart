import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/invoice/cancel_booking_usecase.dart';
import 'cancel_event.dart';
import 'cancel_state.dart';



class CancelBloc extends Bloc<CancelEvent, CancelState> {
  final CancelBookingUseCase cancelUseCase;

  CancelBloc(this.cancelUseCase) : super(CancelInitial()) {
    on<SubmitCancelRequest>((event, emit) async {
      emit(CancelLoading());
      try {
        await cancelUseCase(bookingId: event.bookingId, reason: event.reason);
        emit(CancelSuccess());
      } catch (e) {
        emit(CancelError(e.toString()));
      }
    });
  }
}