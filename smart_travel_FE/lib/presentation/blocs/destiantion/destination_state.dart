import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/destinations.dart';

abstract class DestinationState extends Equatable {
  const DestinationState();

  @override
  List<Object?> get props => [];
}
// State khi đang load
class DestinationLoading extends DestinationState {}

// State khi load thành công
class DestinationLoaded extends DestinationState {
  final List<DestinationEntity> destinations;

  const DestinationLoaded(this.destinations);

  @override
  List<Object?> get props => [destinations];
}

// State khi có lỗi
class DestinationError extends DestinationState {
  final String message;

  const DestinationError(this.message);

  @override
  List<Object?> get props => [message];
}