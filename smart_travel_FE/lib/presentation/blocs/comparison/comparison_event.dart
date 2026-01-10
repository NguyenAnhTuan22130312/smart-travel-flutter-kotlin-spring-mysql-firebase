import 'package:equatable/equatable.dart';

abstract class ComparisonEvent extends Equatable {
  const ComparisonEvent();
  @override
  List<Object?> get props => [];
}

class LoadTourSelectionList extends ComparisonEvent {}
class LoadHotelSelectionList extends ComparisonEvent {}