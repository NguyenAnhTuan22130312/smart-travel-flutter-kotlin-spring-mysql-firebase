import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_featured_use_case.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final GetAllDestinationFeaturedUseCase destinationFeaturedUseCase;

  DestinationBloc({required this.destinationFeaturedUseCase})
      : super(DestinationLoading()) {
    on<LoadFeaturedDestinations>(_onLoadFeaturedDestinations);
  }
  Future<void> _onLoadFeaturedDestinations(
      LoadFeaturedDestinations event,
      Emitter<DestinationState> emit,
      ) async {
    emit(DestinationLoading());

    final result = await destinationFeaturedUseCase(const NoParams());

    result.fold(
          (failure) => emit(DestinationError(failure.message)),
          (destinations) => emit(DestinationLoaded(destinations)),
    );
  }


}