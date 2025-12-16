import 'package:flutter_bloc/flutter_bloc.dart';
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
      emit(state.copyWith(
        loading: false,
        tours: result,
      ));
    } catch (e) {
      print("ERROR in LoadToursEvent: $e");

      emit(state.copyWith(
        loading: false,
        tours: [],
        error: e.toString(),
      ));
    }
  }


  Future<void> _onSearchTours(
      SearchTourEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(loading: true));

    final params = TourFilterParams(keyword: event.keyword);

    final result = await filterTourUseCase(params);

    emit(state.copyWith(
      loading: false,
      tours: result,
    ));
  }
}
