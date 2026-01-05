import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/voucher.dart';
import 'package:smart_travel/domain/params/voucher_params.dart';

abstract class VoucherRepository {
  Future<Either<Failure, List<Voucher>>> getAllVouchers();
  Future<Either<Failure, Voucher>> createVoucher(VoucherCreateParams params);
  Future<Either<Failure, Voucher>> updateVoucher(VoucherUpdateParams params);
  Future<Either<Failure, void>> deleteVoucher(int id);
}