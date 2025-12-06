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

    // 1. Luôn emit Loading để UI hiện vòng quay khi người dùng bấm số trang khác
    emit(HotelLoading());

    // 2. Gọi API lấy dữ liệu đúng trang (event.page)
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
      sortBy: event.sortBy,
      sortDir: event.sortDir,
    ));

    result.fold(
          (failure) => emit(HotelError(failure.message)),
          (pageData) {
        // 3. Emit dữ liệu mới (Thay thế hoàn toàn list cũ)
        emit(HotelLoaded(
          hotels: pageData.content,         // Chỉ lấy 10 item của trang hiện tại
          currentPage: pageData.pageNumber, // Trang hiện tại (ví dụ: 0)
          totalPages: pageData.totalPages,  // Tổng số trang (ví dụ: 2)
        ));
      },
    );
  }
}