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

  const FeaturedDestinationLoaded(this.destinations);

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
  FilterDestinationLoaded(this.destinations);
}

class FilterDestinationError extends DestinationState {
  final String message;
  FilterDestinationError(this.message);
}




