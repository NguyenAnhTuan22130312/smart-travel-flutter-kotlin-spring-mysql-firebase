  import 'dart:async';

  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/province.dart';
  import 'package:smart_travel/domain/usecases/province/add_province_use_case.dart';
  import 'package:smart_travel/domain/usecases/province/delete_province_use_case.dart';
  import 'package:smart_travel/domain/usecases/province/get_all_province_use_case.dart';
import 'package:smart_travel/domain/usecases/province/update_province_use_case.dart';
  import 'package:smart_travel/presentation/blocs/province/province_event.dart';
  import 'package:smart_travel/presentation/blocs/province/province_state.dart';

  class ProvinceBloc extends Bloc<ProvinceEvent, ProvinceState> {
    final GetAllProvinceUseCase getAllProvinceUseCase;
    final AddProvinceUseCase addProvinceUseCase;
    final UpdateProvinceUseCase updateProvinceUseCase;
    final DeleteProvinceUseCase deleteProvinceUseCase;

    ProvinceBloc(
        {required this.getAllProvinceUseCase,
          required this.addProvinceUseCase,
          required this.deleteProvinceUseCase,
          required this.updateProvinceUseCase})
        : super(ProvinceLoading()) {
      on<LoadProvince>(_onLoadProvince);
      on<AddProvince>(_onAddProvince);
      on<DeleteProvince>(_onDeleteProvince);
      on<UpdateProvince>(_onUpdateProvince);
    }



    ///load danh sách tỉnh thành
    FutureOr<void> _onLoadProvince(LoadProvince event,
        Emitter<ProvinceState> emit,) async {
      emit(ProvinceLoading());
      final result = await getAllProvinceUseCase(const NoParams());

      result.fold(
            (failure) => emit(ProvinceError(failure.message)),
            (province) {
              List<ProvinceEntity> list = province;
              if(event.loadAll == false){
                list = province.take(6).toList();
              }
              emit(ProvinceLoaded(list));
            }
      );
    }

    ///thêm tỉnh thành
    FutureOr<void> _onAddProvince(AddProvince event,
        Emitter<ProvinceState> emit,) async {
      emit(ProvinceAdding());
      final result = await addProvinceUseCase(event.params);
      result.fold(
            (failure) => emit(AddProvinceError(failure.message)),
            (success) => emit(ProvinceAddSuccess()),
      );
      add(LoadProvince());
    }

    ///Xóa tỉnh thành
    FutureOr<void> _onDeleteProvince(DeleteProvince event,
        Emitter<ProvinceState> emit) async {
      final result = await deleteProvinceUseCase(event.provinceId);
      result.fold(
            (failure) async{
              emit(ProvinceDeleteError(failure.message));
              add(LoadProvince());
            },
            (success) {
          emit(ProvinceDeleteSuccess());
          add(LoadProvince());
        },
      );
    }

    FutureOr<void> _onUpdateProvince(
        UpdateProvince event,
        Emitter<ProvinceState> emit) async {

      emit(ProvinceUpdateLoading());

      final result = await updateProvinceUseCase(event.params);

      await result.fold(
            (failure) async {
          emit(ProvinceUpdateError(failure.message));
          add(LoadProvince());
        },
            (success) async {
          emit(ProvinceUpdateSuccess());
          add(LoadProvince());
        },
      );
    }
}
