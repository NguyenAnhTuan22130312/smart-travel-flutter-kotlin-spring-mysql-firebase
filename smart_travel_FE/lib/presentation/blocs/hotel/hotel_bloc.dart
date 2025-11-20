import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/hotel/get_hotels_use_case.dart';
import 'hotel_event.dart';
import 'hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final GetHotelsUseCase getHotelsUseCase;

  HotelBloc({required this.getHotelsUseCase}) : super(HotelInitial()) {
    on<LoadHotelsEvent>(_onLoadHotelsEvent);
  }

  Future<void> _onLoadHotelsEvent(
      LoadHotelsEvent event, Emitter<HotelState> emit) async {
    emit(HotelLoading());

    try {
      final result = await getHotelsUseCase(GetHotelsParams(
        destinationId: event.destinationId,
        keyword: event.keyword,
        minStars: event.minStars,
        maxStars: event.maxStars,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        city: event.city,
        page: event.page,
        size: event.size,
      ));

      result.fold(
            (failure) => emit(HotelError(failure.message)),
            (hotels) => emit(HotelLoaded(hotels)),
      );
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }
}
