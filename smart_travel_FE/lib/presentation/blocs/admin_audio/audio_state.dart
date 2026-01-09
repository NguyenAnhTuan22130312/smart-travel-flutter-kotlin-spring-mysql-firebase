import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/destinations.dart';

abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}
class AudioLoading extends AudioState {}

class AudioDestinationsLoaded extends AudioState {
  final List<DestinationEntity> destinations;
  const AudioDestinationsLoaded(this.destinations);

  @override
  List<Object?> get props => [destinations];
}

class AudioUpdateSuccess extends AudioState {
  final DestinationEntity destination;

  const AudioUpdateSuccess(this.destination);
}

class AudioError extends AudioState {
  final String message;

  const AudioError(this.message);
}
