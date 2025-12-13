import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/tour.dart';

class TourState extends Equatable {
  final bool loading;
  final List<Tour> tours;
  final String? error;

  const TourState({
    this.loading = false,
    this.tours = const [],
    this.error,
  });

  TourState copyWith({
    bool? loading,
    List<Tour>? tours,
    String? error,
  }) {
    return TourState(
      loading: loading ?? this.loading,
      tours: tours ?? this.tours,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, tours, error];
}
