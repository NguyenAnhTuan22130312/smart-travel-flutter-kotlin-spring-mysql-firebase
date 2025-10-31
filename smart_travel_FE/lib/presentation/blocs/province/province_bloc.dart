import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/usecases/province/get_all_province_use_case.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';

class ProvinceBloc extends Bloc<ProvinceEvent, ProvinceState> {
  final GetAllProvinceUseCase getAllProvinceUseCase;

  ProvinceBloc({required this.getAllProvinceUseCase})
    : super(ProvinceLoading()) {
    on<LoadProvinceIsPopular>(_onLoadProvinceIsPopular);
    on<LoadProvince>(_onLoadProvince);
  }

  FutureOr<void> _onLoadProvinceIsPopular(
    LoadProvinceIsPopular event,
    Emitter<ProvinceState> emit,
  ) async {
    emit(ProvinceLoading());
    final result = await getAllProvinceUseCase(const NoParams());

    result.fold(
      (failure) => emit(ProvinceError(failure.message)),
      (province) {
        final popularProvinces = province.where((e) => e.isPopular == true)
            .toList();
        emit(ProvincePopularLoaded(popularProvinces));
      },
    );
  }

  FutureOr<void> _onLoadProvince(
      LoadProvince event,
      Emitter<ProvinceState> emit,
      ) async {
    emit(ProvinceLoading());
    final result = await getAllProvinceUseCase(const NoParams());

    result.fold(
          (failure) => emit(ProvinceError(failure.message)),
          (province) => emit(ProvinceLoaded(province)),
    );
  }
}
