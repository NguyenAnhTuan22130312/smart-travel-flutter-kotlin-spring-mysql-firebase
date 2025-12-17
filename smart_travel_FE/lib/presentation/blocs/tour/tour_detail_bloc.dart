import 'package:flutter_bloc/flutter_bloc.dart';
import 'tour_detail_event.dart';
import 'tour_detail_state.dart';
import 'package:smart_travel/domain/usecases/tour/get_tour_detail_usecase.dart';

class TourDetailBloc extends Bloc<TourDetailEvent, TourDetailState> {
  final GetTourDetailUseCase getDetail;

  TourDetailBloc(this.getDetail) : super(TourDetailState()) {
    on<LoadTourDetail>(_loadDetail);
  }

  Future<void> _loadDetail(
      LoadTourDetail event, Emitter<TourDetailState> emit) async {
    emit(state.copyWith(loading: true));

    try {
      final detail = await getDetail(event.id);
      emit(state.copyWith(loading: false, detail: detail));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
