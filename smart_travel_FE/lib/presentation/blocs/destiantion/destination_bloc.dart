import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/usecases/destination/filter_destinations_by_category_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_featured_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_use_case.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final GetAllDestinationFeaturedUseCase destinationFeaturedUseCase;
  final GetAllDestinationsUseCase getAllDestinationUseCase;
  final FilterDestinationsByCategoryUseCase filterByCategoryUseCase;

  DestinationBloc({required this.destinationFeaturedUseCase,
  required this.filterByCategoryUseCase, required this.getAllDestinationUseCase})
      : super(FeaturedDestinationInitial()) {
    on<LoadFeaturedDestinations>(_onLoadFeaturedDestinations);

    on<LoadAllDestinations>(_onLoadAllDestinations);
    on<FilterDestinationsByCategory>(_onFilterDestinationsByCategory);
  }
  Future<void> _onLoadFeaturedDestinations(
      LoadFeaturedDestinations event,
      Emitter<DestinationState> emit,
      ) async {
    emit(FeaturedDestinationLoading());

    final result = await destinationFeaturedUseCase(const NoParams());

    result.fold(
          (failure) => emit(FeaturedDestinationError(failure.message)),
          (destinations) => emit(FeaturedDestinationLoaded(destinations)),
    );
  }

  Future<void> _onLoadAllDestinations(
      LoadAllDestinations event,
      Emitter<DestinationState> emit,
      ) async {
    emit(FilterDestinationLoading());

    final result = await getAllDestinationUseCase(const NoParams());

    result.fold(
          (failure) => emit(FilterDestinationError(failure.message)),
          (destinations) => emit(FilterDestinationLoaded(destinations)),
    );
  }

  Future<void> _onFilterDestinationsByCategory(
      FilterDestinationsByCategory event,
      Emitter<DestinationState> emit,
      ) async {
    emit(FilterDestinationLoading());

    final result = await filterByCategoryUseCase(event.category);

    result.fold(
          (failure) => emit(FilterDestinationError(failure.message)),
          (destinations) => emit(FilterDestinationLoaded(destinations)),
    );
  }

}