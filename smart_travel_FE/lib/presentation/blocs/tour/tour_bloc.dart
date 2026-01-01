import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/data/models/tour/tour_summary_response_modal.dart';
import 'package:smart_travel/domain/entities/tour.dart';
import 'package:smart_travel/domain/usecases/tour/filter_tour_usecase.dart';
import 'tour_event.dart';
import 'tour_state.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  final FilterToursUseCase filterTourUseCase;

  TourBloc(this.filterTourUseCase) : super(const TourState()) {
    on<LoadToursEvent>(_onLoadTours);
    on<SearchTourEvent>(_onSearchTours);
  }

  Future<void> _onLoadTours(LoadToursEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final result = await filterTourUseCase(event.params);

      // result bây giờ là Map từ Server trả về
      final List<dynamic> content = result['content'] ?? [];

      emit(state.copyWith(
        loading: false,
        // Map từng item trong content sang Entity Tour thông qua Model
        tours: content.map((e) => TourSummaryResponse.fromJson(e).toEntity()).toList(),
        currentPage: result['number'] ?? 0,
        totalPages: result['totalPages'] ?? 1, // GIỜ NÓ SẼ CÓ GIÁ TRỊ THẬT (> 1)
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onSearchTours(SearchTourEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(loading: true));
    final params = TourFilterParams(keyword: event.keyword, page: 0); // Reset về trang 0 khi search

    try {
      final result = await filterTourUseCase(params);
      emit(state.copyWith(
        loading: false,
        tours: result.content,
        currentPage: result.number,
        totalPages: result.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
