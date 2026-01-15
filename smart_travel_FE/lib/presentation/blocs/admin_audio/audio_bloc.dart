import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/params/audio_params.dart';
import 'package:smart_travel/domain/usecases/audio/add_audio_use_case.dart';
import 'package:smart_travel/domain/usecases/audio/delete_audio_use_case.dart';
import 'package:smart_travel/domain/usecases/audio/edit_audio_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/update_destination_use_case.dart';
import 'audio_event.dart';
import 'audio_state.dart';
class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final UpdateDestinationUseCase updateDestinationUseCase;
  final GetAllDestinationsUseCase getAllDestinationsUseCase;
  final AddAudioUseCase addAudioUseCase;
  final EditAudioUseCase editAudioUseCase;
  final DeleteAudioUseCase deleteAudioUseCase;

  AudioBloc({
    required this.addAudioUseCase,
    required this.editAudioUseCase,
    required this.deleteAudioUseCase,
    required this.updateDestinationUseCase,
    required this.getAllDestinationsUseCase,
  }) : super(AudioInitial()) {
    on<LoadAudioDestinations>(_onLoadDestinations);
    on<AddAudioScriptEvent>(_onAddAudio);
    on<UpdateDestinationAudioEvent>(_onUpdateAudio);
    on<DeleteAudioScriptEvent>(_onDeleteAudio);
  }

  FutureOr<void> _onLoadDestinations(
      LoadAudioDestinations event,
      Emitter<AudioState> emit,
      ) async {
    emit(AudioLoading());
    final result = await getAllDestinationsUseCase(const NoParams());
    result.fold(
          (failure) => emit(AudioError(failure.message)),
          (destinations) => emit(AudioDestinationsLoaded(destinations)),
    );
  }

  // ADD AUDIO
  FutureOr<void> _onAddAudio(
      AddAudioScriptEvent event,
      Emitter<AudioState> emit,
      ) async {
    emit(AudioLoading());
    final params = AudioParams(
      destinationId: event.id,
      audioScript: event.audioScript,
    );
    final result = await addAudioUseCase(params); // Gọi AddAudioUseCase
    result.fold(
          (failure) => emit(AudioError(failure.message)),
          (destination) => emit(AudioUpdateSuccess(destination)),
    );
  }

  // UPDATE AUDIO
  FutureOr<void> _onUpdateAudio(
      UpdateDestinationAudioEvent event,
      Emitter<AudioState> emit,
      ) async {
    emit(AudioLoading());
    final params = AudioParams(
      destinationId: event.id,
      audioScript: event.audioScript,
    );
    final result = await editAudioUseCase(params);
    result.fold(
          (failure) => emit(AudioError(failure.message)),
          (destination) => emit(AudioUpdateSuccess(destination)),
    );
  }

  // DELETE AUDIO
  FutureOr<void> _onDeleteAudio(
      DeleteAudioScriptEvent event,
      Emitter<AudioState> emit,
      ) async {
    emit(AudioLoading());
    final result = await deleteAudioUseCase(event.id);
    result.fold(
          (failure) => emit(AudioError(failure.message)),
          (destination) {
        emit(AudioUpdateSuccess(destination));
        add(LoadAudioDestinations());
      },
    );
  }
}