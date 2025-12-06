import 'package:equatable/equatable.dart';

abstract class TourEvent {}

class LoadTourDetail extends TourEvent {
  final int id;
  LoadTourDetail(this.id);
}

