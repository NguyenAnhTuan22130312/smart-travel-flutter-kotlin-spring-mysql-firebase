import 'package:flutter_bloc/flutter_bloc.dart';
import 'tour_event.dart';
import 'tour_state.dart';
import 'package:smart_travel/domain/usecases/tour/get_tour_detail_usecase.dart';

class TourBloc extends Bloc<TourEvent, TourState> {
  final GetTourDetailUseCase getDetail;

  TourBloc(this.getDetail) : super(TourState()) {
    on<LoadTourDetail>(_loadDetail);
  }

  Future<void> _loadDetail(
      LoadTourDetail event, Emitter<TourState> emit) async {
    emit(state.copyWith(loading: true));

    try {
      final detail = await getDetail(event.id);
      emit(state.copyWith(loading: false, detail: detail));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
