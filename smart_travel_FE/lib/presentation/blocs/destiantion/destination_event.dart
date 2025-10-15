import 'package:equatable/equatable.dart';

abstract class DestinationEvent extends Equatable {

  @override
  List<Object?> get props => [];
}
// load danh sách điểm đến nổi bật
class LoadFeaturedDestinations extends DestinationEvent {}