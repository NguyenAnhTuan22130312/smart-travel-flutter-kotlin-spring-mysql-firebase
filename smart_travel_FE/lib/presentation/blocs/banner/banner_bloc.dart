import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/usecases/banner/create_banner_uc.dart';
import 'package:smart_travel/domain/usecases/banner/delete_banner_uc.dart';
import 'package:smart_travel/domain/usecases/banner/get_all_banner_use_case.dart';
import 'package:smart_travel/domain/usecases/banner/update_banner_uc.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_event.dart';
import 'package:smart_travel/presentation/blocs/banner/banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState>{
  final GetAllBannerUseCase allBannerUseCase;
  final CreateBannerUc createBannerUseCase;
  final UpdateBannerUc updateBannerUseCase;
  final DeleteBannerUc deleteBannerUseCase;

  BannerBloc({required this.allBannerUseCase,
    required this.createBannerUseCase,
    required this.updateBannerUseCase,
    required this.deleteBannerUseCase,})
      : super(BannerInitial()) {
    on<LoadAllBanner>(_onLoadAllBanner);
    on<CreateBannerEvent>(_onCreateBanner);
    on<UpdateBannerEvent>(_onUpdateBanner);
    on<DeleteBannerEvent>(_onDeleteBanner);
  }

  FutureOr<void> _onLoadAllBanner(
      LoadAllBanner event,
      Emitter<BannerState> emit) async{
      emit(BannerDataLoading());
      final results = await allBannerUseCase(NoParams());
      print(results);
      results.fold((failure) =>
        emit(BannerDataError(failure.message))
      ,
          (success) =>
        emit(BannerData(success))
      );
  }
  FutureOr<void> _onCreateBanner(
      CreateBannerEvent event, Emitter<BannerState> emit) async {
    emit(BannerActionLoading());
    final results = await createBannerUseCase(event.params);

    results.fold(
          (failure) => emit(BannerActionError(failure.message)),
          (success) {
        emit(BannerActionSuccess(message: "Thêm banner thành công!", banner: success));
        add(LoadAllBanner());
      },
    );
  }

  FutureOr<void> _onUpdateBanner(
      UpdateBannerEvent event, Emitter<BannerState> emit) async {
    emit(BannerActionLoading());
    final results = await updateBannerUseCase(event.params);

    results.fold(
          (failure) => emit(BannerActionError(failure.message)),
          (success) {
        emit(BannerActionSuccess(message: "Cập nhật thành công!", banner: success));
        add(LoadAllBanner());
      },
    );
  }

  FutureOr<void> _onDeleteBanner(
      DeleteBannerEvent event, Emitter<BannerState> emit) async {
    emit(BannerActionLoading());
    final results = await deleteBannerUseCase(event.id);

    results.fold(
          (failure) => emit(BannerActionError(failure.message)),
          (success) {
        emit(const BannerActionSuccess(message: "Xóa banner thành công!"));
        add(LoadAllBanner());
      },
    );
  }
}

