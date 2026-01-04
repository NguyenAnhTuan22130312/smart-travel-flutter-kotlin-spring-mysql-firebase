import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/params/voucher_params.dart';

abstract class VoucherEvent extends Equatable {
  const VoucherEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllVoucher extends VoucherEvent {}

class CreateVoucherEvent extends VoucherEvent {
  final VoucherCreateParams params;
  const CreateVoucherEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class UpdateVoucherEvent extends VoucherEvent {
  final VoucherUpdateParams params;
  const UpdateVoucherEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class DeleteVoucherEvent extends VoucherEvent {
  final int id;
  const DeleteVoucherEvent(this.id);
  @override
  List<Object?> get props => [id];
}