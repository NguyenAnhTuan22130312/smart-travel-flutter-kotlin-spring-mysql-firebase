import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';

abstract class TourEvent extends Equatable {
  const TourEvent();
  @override
  List<Object?> get props => [];
}

class LoadToursEvent extends TourEvent {
  final TourFilterParams params;
  LoadToursEvent(this.params);

  @override
  List<Object> get props => [params];
}

class SearchTourEvent extends TourEvent {
  final String keyword;
  SearchTourEvent(this.keyword);

  @override
  List<Object?> get props => [keyword];
}
