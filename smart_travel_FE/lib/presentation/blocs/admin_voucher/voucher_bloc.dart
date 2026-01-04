import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/usecases/voucher/get_all_voucher_uc.dart';
import 'package:smart_travel/domain/usecases/voucher/create_voucher_uc.dart';
import 'package:smart_travel/domain/usecases/voucher/update_voucher_uc.dart';
import 'package:smart_travel/domain/usecases/voucher/delete_voucher_uc.dart';
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_event.dart';
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_state.dart';
import 'package:smart_travel/core/usecases/usecase.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final GetAllVoucherUc getAllVoucherUc;
  final CreateVoucherUc createVoucherUc;
  final UpdateVoucherUc updateVoucherUc;
  final DeleteVoucherUc deleteVoucherUc;

  VoucherBloc({
    required this.getAllVoucherUc,
    required this.createVoucherUc,
    required this.updateVoucherUc,
    required this.deleteVoucherUc,
  }) : super(VoucherInitial()) {
    on<LoadAllVoucher>(_onLoadAll);
    on<CreateVoucherEvent>(_onCreate);
    on<UpdateVoucherEvent>(_onUpdate);
    on<DeleteVoucherEvent>(_onDelete);
  }

  FutureOr<void> _onLoadAll(LoadAllVoucher event, Emitter<VoucherState> emit) async {
    emit(VoucherDataLoading());
    final result = await getAllVoucherUc(NoParams());
    result.fold(
          (failure) => emit(VoucherDataError(failure.message)),
          (data) => emit(VoucherDataLoaded(data)),
    );
  }

  FutureOr<void> _onCreate(CreateVoucherEvent event, Emitter<VoucherState> emit) async {
    emit(VoucherActionLoading());
    final result = await createVoucherUc(event.params);
    result.fold(
          (failure) => emit(VoucherActionError(failure.message)),
          (success) {
        emit(const VoucherActionSuccess(message: "Tạo Voucher thành công!"));
        add(LoadAllVoucher());
      },
    );
  }

  FutureOr<void> _onUpdate(UpdateVoucherEvent event, Emitter<VoucherState> emit) async {
    emit(VoucherActionLoading());
    final result = await updateVoucherUc(event.params);
    result.fold(
          (failure) => emit(VoucherActionError(failure.message)),
          (success) {
        emit(const VoucherActionSuccess(message: "Cập nhật thành công!"));
        add(LoadAllVoucher());
      },
    );
  }

  FutureOr<void> _onDelete(DeleteVoucherEvent event, Emitter<VoucherState> emit) async {
    emit(VoucherActionLoading());
    final result = await deleteVoucherUc(event.id);
    result.fold(
          (failure) => emit(VoucherActionError(failure.message)),
          (success) {
        emit(const VoucherActionSuccess(message: "Xóa Voucher thành công!"));
        add(LoadAllVoucher());
      },
    );
  }
}