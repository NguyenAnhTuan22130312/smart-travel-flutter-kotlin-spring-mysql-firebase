import 'package:smart_travel/domain/entities/tour_detail.dart';

class TourState {
  final bool loading;
  final TourDetail? detail;
  final String? error;

  TourState({this.loading = false, this.detail, this.error});

  TourState copyWith({bool? loading, TourDetail? detail, String? error}) {
    return TourState(
      loading: loading ?? this.loading,
      detail: detail ?? this.detail,
      error: error,
    );
  }
}
