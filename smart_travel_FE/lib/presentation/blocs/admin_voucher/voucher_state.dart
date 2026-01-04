import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/voucher.dart';

abstract class VoucherState extends Equatable {
  const VoucherState();
  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {}

// --- STATE LOAD DATA ---
class VoucherDataLoading extends VoucherState {}

class VoucherDataLoaded extends VoucherState {
  final List<Voucher> vouchers;
  const VoucherDataLoaded(this.vouchers);
  @override
  List<Object?> get props => [vouchers];
}

class VoucherDataError extends VoucherState {
  final String message;
  const VoucherDataError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- STATE ACTION (Create/Update/Delete) ---
class VoucherActionLoading extends VoucherState {}

class VoucherActionSuccess extends VoucherState {
  final String message;
  const VoucherActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class VoucherActionError extends VoucherState {
  final String message;
  const VoucherActionError(this.message);
  @override
  List<Object?> get props => [message];
}