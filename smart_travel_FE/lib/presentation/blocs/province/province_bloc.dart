import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/usecases/province/get_all_province_is_popular_use_case.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';

class ProvinceBloc extends Bloc<ProvinceEvent, ProvinceState> {
  final GetAllProvinceIsPopularUseCase getAllProvinceIsPopularUseCase;

  ProvinceBloc({required this.getAllProvinceIsPopularUseCase})
    : super(ProvinceLoading()) {
    on<LoadProvinceIsPopular>(_onLoadProvinceIsPopular);
  }

  FutureOr<void> _onLoadProvinceIsPopular(
    LoadProvinceIsPopular event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(ProvinceLoading());
    final result = await getAllProvinceIsPopularUseCase(const NoParams());

    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (province) => emit(ProvinceLoaded(province)),
    );
  }
}
