import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/hotel/hotel_detail_use_case.dart';
import 'hotel_detail_event.dart';
import 'hotel_detail_state.dart';

class HotelDetailBloc extends Bloc<HotelDetailEvent, HotelDetailState> {
  final HotelDetailUseCase hotelDetailUseCase;

  HotelDetailBloc({required this.hotelDetailUseCase})
    : super(HotelDetailInitial()) {
    on<GetHotelDetailEvent>(_onGetHotelDetailEvent);
  }

  Future<void> _onGetHotelDetailEvent(
    GetHotelDetailEvent event,
    Emitter<HotelDetailState> emit,
  ) async {
    emit(HotelDetailLoading());
    try {
      final result = await hotelDetailUseCase(
        HotelDetailParams(
          hotelId: event.hotelId,
          checkIn: event.checkIn,
          checkOut: event.checkOut,
        ),
      );

      result.fold(
        (failure) => emit(HotelDetailError(failure.message)),
        (hotelDetail) => emit(HotelDetailLoaded(hotelDetail)),
      );
    } catch (e) {
      emit(HotelDetailError(e.toString()));
    }
  }
}
