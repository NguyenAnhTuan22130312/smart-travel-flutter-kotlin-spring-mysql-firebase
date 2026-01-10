import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_travel/domain/repositories/tour_repository.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import '../../../domain/repositories/comparison_repository.dart';
import 'comparison_event.dart';
import 'comparison_state.dart';

class ComparisonBloc extends Bloc<ComparisonEvent, ComparisonState> {
  final ComparisonRepository comparisonRepository;
  final TourRepository tourRepository;
  final HotelRepository hotelRepository;

  List<dynamic> _toursCache = [];
  List<Hotel> _hotelsCache = [];

  ComparisonBloc({
    required this.comparisonRepository,
    required this.tourRepository,
    required this.hotelRepository,
  }) : super(ComparisonInitial()) {
    on<LoadTourSelectionList>(_onLoadTours);
    on<LoadHotelSelectionList>(_onLoadHotels);
  }

  // 1. Load Tour List
  Future<void> _onLoadTours(LoadTourSelectionList event, Emitter<ComparisonState> emit) async {
    // Chỉ hiện loading nếu chưa có dữ liệu
    if (state is! ComparisonSelectionLoaded) emit(ComparisonLoading());

    try {
      final result = await tourRepository.getTours(page: 0, size: 50);

      // Xử lý dữ liệu trả về (vì repo trả về dynamic)
      List<dynamic> tourList = [];
      if (result is List) {
        tourList = result;
      } else if (result is Map && result.containsKey('content')) {
        tourList = result['content'];
      }

      _toursCache = tourList;
      emit(ComparisonSelectionLoaded(tours: _toursCache, hotels: _hotelsCache));
    } catch (e) {
      emit(ComparisonError("Lỗi tải danh sách Tour: $e"));
    }
  }

  // 2. Load Hotel List
  Future<void> _onLoadHotels(LoadHotelSelectionList event, Emitter<ComparisonState> emit) async {
    if (state is! ComparisonSelectionLoaded) emit(ComparisonLoading());

    final result = await hotelRepository.getHotels(page: 0, size: 50);

    result.fold(
          (failure) => emit(ComparisonError(failure.message)),
          (hotelsPage) {
        // SỬA Ở ĐÂY: đổi .items thành .hotels (hoặc .content tùy vào entity của bạn)
        _hotelsCache = hotelsPage.content;

        emit(ComparisonSelectionLoaded(tours: _toursCache, hotels: _hotelsCache));
      },
    );
  }
}