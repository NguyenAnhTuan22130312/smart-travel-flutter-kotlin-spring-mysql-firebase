import 'package:equatable/equatable.dart';

abstract class TourDetailEvent {}

class LoadTourDetail extends TourDetailEvent {
  final int id;
  LoadTourDetail(this.id);
}

