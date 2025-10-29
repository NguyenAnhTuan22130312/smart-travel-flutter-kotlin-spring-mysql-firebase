import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/destinations.dart';

abstract class DestinationState extends Equatable {
  const DestinationState();

  @override
  List<Object?> get props => [];
}
class FeaturedDestinationInitial extends DestinationState {}
// State khi đang load
class FeaturedDestinationLoading extends DestinationState {}

// State khi load thành công
class FeaturedDestinationLoaded extends DestinationState {
  final List<DestinationEntity> destinations;
  final bool isLimited;

  const FeaturedDestinationLoaded(this.destinations, {this.isLimited = false});

  @override
  List<Object?> get props => [destinations];
}
// State khi có lỗi
class FeaturedDestinationError extends DestinationState {
  final String message;

  const FeaturedDestinationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// Filter Destinations States (by category)
// ============================================================

class FilterDestinationInitial extends DestinationState {}

class FilterDestinationLoading extends DestinationState {}

class FilterDestinationLoaded extends DestinationState {
  final List<DestinationEntity> destinations;
  final bool isLimited;

  FilterDestinationLoaded(this.destinations, {this.isLimited = false}); // true = chỉ load 6, có thể hiện "Xem tất cả"

}

class FilterDestinationError extends DestinationState {
  final String message;
  FilterDestinationError(this.message);
}




