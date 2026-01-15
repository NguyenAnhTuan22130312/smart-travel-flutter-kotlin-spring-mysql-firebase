import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/usecases/destination/CompleteVoiceUseCase.dart';
import 'package:smart_travel/domain/usecases/destination/add_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/delete_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/filter_destinations_by_category_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_featured_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_all_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_detail_destination_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/get_weather_use_case.dart';
import 'package:smart_travel/domain/usecases/destination/update_destination_use_case.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_detail_state.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final GetAllDestinationFeaturedUseCase destinationFeaturedUseCase;
  final GetAllDestinationsUseCase getAllDestinationUseCase;
  final FilterDestinationsByCategoryUseCase filterByCategoryUseCase;
  final AddDestinationUseCase addDestinationUseCase;
  final UpdateDestinationUseCase updateDestinationUseCase;
  final DeleteDestinationUseCase deleteDestinationUseCase;
  final GetWeatherUseCase getWeatherUseCase;
  final CompleteVoiceUseCase completeVoiceUseCase;

  DestinationBloc({
    required this.destinationFeaturedUseCase,
    required this.filterByCategoryUseCase,
    required this.getAllDestinationUseCase,
    required this.addDestinationUseCase,
    required this.updateDestinationUseCase,
    required this.deleteDestinationUseCase,
    required this.getWeatherUseCase,
    required this.completeVoiceUseCase,
  }) : super(FeaturedDestinationInitial()) {
    on<LoadAllDestinations>(_onLoadAllDestinations);
    on<FilterDestinationsByCategory>(_onFilterDestinationsByCategory);
    on<FilterDestinationsEvent>(_onFilterDestinationsEvent);
    on<SearchDestinationEvent>(_onSearchDestinationEvent);
    on<AddDestinationEvent>(_onAddDestinationEvent);
    on<UpdateDestinationEvent>(_onUpdateDestinationEvent);
    on<DeleteDestinationEvent>(_onDeleteDestinationEvent);
    on<CompleteVoiceEvent>(_onCompleteVoiceEvent);
  }

  ///Lấy tất cả danh sách địa điểm
  Future<void> _onLoadAllDestinations(
    LoadAllDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    emit(FilterDestinationLoading());

    final result = await getAllDestinationUseCase(const NoParams());

    result.fold((failure) => emit(FilterDestinationError(failure.message)), (
      destinations,
    ) {
      List<DestinationEntity> displayList = destinations;

      // Nếu loadAll == false chỉ lấy 6 cái
      if (event.loadAll == false) {
        displayList = destinations.take(6).toList();
      }

      emit(
        FilterDestinationLoaded(
          displayList,
          isLimited: event.loadAll == false, // true nếu chỉ load 6
        ),
      );
    });
  }

  /// Lấy danh sách địa điểm theo danh mục
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

  /// Lọc danh sách địa điểm
  Future<void> _onFilterDestinationsEvent(
    FilterDestinationsEvent event,
    Emitter<DestinationState> emit,
  ) async {
    emit(FilterDestinationLoading());

    try {
      final result = await getAllDestinationUseCase(const NoParams());

      result.fold(
        (failure) {
          emit(FilterDestinationError(failure.message));
        },
        (destinations) {
          var filteredDestinations = List.of(destinations);

          // Lọc theo khoảng giá
          final minPrice = event.minPrice;
          final maxPrice = event.maxPrice;
          if (minPrice != null && maxPrice != null && minPrice <= maxPrice) {
            filteredDestinations =
                filteredDestinations
                    .where(
                      (d) => d.entryFee! >= minPrice && d.entryFee! <= maxPrice,
                    )
                    .toList();
          }

          // Lọc theo rating
          final minRating = event.minRating;
          if (minRating != null && minRating > 0) {
            filteredDestinations =
                filteredDestinations
                    .where((d) => d.averageRating >= minRating)
                    .toList();
          }

          // Sắp xếp
          switch (event.sortBy) {
            case 'rating':
              filteredDestinations.sort(
                (a, b) => b.averageRating.compareTo(a.averageRating),
              );
              break;
            case 'price_low':
              filteredDestinations.sort(
                (a, b) => a.entryFee!.compareTo(b.entryFee!),
              );
              break;
            case 'price_high':
              filteredDestinations.sort(
                (a, b) => b.entryFee!.compareTo(a.entryFee!),
              );
              break;
            case 'popular':
            default:
              filteredDestinations.sort(
                (a, b) => b.averageRating.compareTo(a.averageRating),
              );
              break;
          }

          emit(FilterDestinationLoaded(filteredDestinations));
        },
      );
    } catch (error, stackTrace) {
      emit(FilterDestinationError(error.toString()));
    }
  }

  ///Tìm kiem địa điểm theo tên và mô tả
  Future<void> _onSearchDestinationEvent(
    SearchDestinationEvent event,
    Emitter<DestinationState> emit,
  ) async {
    emit(FilterDestinationLoading());

    try {
      final result = await getAllDestinationUseCase(const NoParams());

      result.fold((failure) => emit(FilterDestinationError(failure.message)), (
        destinations,
      ) {
        var filteredDestinations = List.of(destinations);

        final query = event.query.toLowerCase().trim();
        if (query.isNotEmpty) {
          filteredDestinations =
              filteredDestinations
                  .where(
                    (d) =>
                        d.name.toLowerCase().contains(query) ||
                        (d.description?.toLowerCase().contains(query) ?? false),
                  )
                  .toList();
        }

        emit(FilterDestinationLoaded(filteredDestinations));
      });
    } catch (e) {
      emit(FilterDestinationError(e.toString()));
    }
  }

  ///Thêm địa điểm
  FutureOr<void> _onAddDestinationEvent(
    AddDestinationEvent event,
    Emitter<DestinationState> emit,
  ) async {
    emit(AddDestinationLoading());
    final result = await addDestinationUseCase(event.destinationAddParams);
    result.fold(
      (failure) {
        emit(AddDestinationError(failure.message));
      },
      (success) {
        emit(AddDestinationSuccess(success));
      },
    );
    add(LoadAllDestinations(loadAll: true));
  }

  ///Cập nhật địa điểm
  FutureOr<void> _onUpdateDestinationEvent(
    UpdateDestinationEvent event,
    Emitter<DestinationState> emit,
  ) async {
    emit(UpdateDestinationLoading());
    final result = await updateDestinationUseCase(
      event.destinationUpdateParams,
    );
    result.fold(
      (failure) {
        emit(UpdateDestinationError(failure.message));
      },
      (success) {
        emit(UpdateDestinationSuccess(success));
      },
    );
    add(LoadAllDestinations(loadAll: true));
  }

  ///Xóa địa điểm
  FutureOr<void> _onDeleteDestinationEvent(
    DeleteDestinationEvent event,
    Emitter<DestinationState> emit,
  ) async {
    emit(DeleteDestinationLoading());

    final result = await deleteDestinationUseCase(event.destinationId);

    result.fold(
      (failure) {
        emit(DeleteDestinationError(failure.message));
      },
      (success) {
        emit(DeleteDestinationSuccess(success));
      },
    );
    add(LoadAllDestinations());
  }

  Future<void> _onCompleteVoiceEvent(
    CompleteVoiceEvent event,
    Emitter<DestinationState> emit,
  ) async {
    // Lưu lại danh sách địa điểm hiện có trước khi chuyển sang Loading
    List<DestinationEntity> currentList = [];
    if (state is FilterDestinationLoaded) {
      currentList = (state as FilterDestinationLoaded).destinations;
    }

    emit(CompleteVoiceLoading());

    final result = await completeVoiceUseCase(event.destinationId);

    result.fold(
      (failure) => emit(CompleteVoiceError(failure.message)),
      (levelData) => emit(
        CompleteVoiceSuccess(
          destinations: currentList, // Trả lại danh sách để UI không bị mất
          levelData: levelData,
          destinationId: event.destinationId,
        ),
      ),
    );
  }
}
