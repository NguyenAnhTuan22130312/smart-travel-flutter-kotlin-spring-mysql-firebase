import 'package:smart_travel/domain/entities/tour_detail.dart';

class TourDetailState {
  final bool loading;
  final TourDetail? detail;
  final String? error;

  TourDetailState({this.loading = false, this.detail, this.error});

  TourDetailState copyWith({bool? loading, TourDetail? detail, String? error}) {
    return TourDetailState(
      loading: loading ?? this.loading,
      detail: detail ?? this.detail,
      error: error,
    );
  }
}