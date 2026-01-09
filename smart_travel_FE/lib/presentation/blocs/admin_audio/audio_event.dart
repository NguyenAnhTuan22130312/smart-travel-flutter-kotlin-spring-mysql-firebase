import 'package:equatable/equatable.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();
  @override
  List<Object?> get props => [];
}

class LoadAudioDestinations extends AudioEvent {}

class AddAudioScriptEvent extends AudioEvent {
  final int id;
  final String audioScript;

  const AddAudioScriptEvent({required this.id, required this.audioScript});

  @override
  List<Object?> get props => [id, audioScript];
}

class UpdateDestinationAudioEvent extends AudioEvent {
  final int id;
  final String audioScript;

  const UpdateDestinationAudioEvent({required this.id, required this.audioScript});

  @override
  List<Object?> get props => [id, audioScript];
}

class DeleteAudioScriptEvent extends AudioEvent {
  final int id;
  const DeleteAudioScriptEvent(this.id);

  @override
  List<Object?> get props => [id];
}