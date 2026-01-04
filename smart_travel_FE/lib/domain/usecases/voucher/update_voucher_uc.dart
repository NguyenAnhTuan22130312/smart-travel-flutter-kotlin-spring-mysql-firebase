import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/voucher.dart';
import '../../params/voucher_params.dart';
import '../../repositories/voucher_repository.dart';


class UpdateVoucherUc extends UseCase<Voucher, VoucherUpdateParams> {
  final VoucherRepository repository;
  UpdateVoucherUc(this.repository);
  @override
  Future<Either<Failure, Voucher>> call(VoucherUpdateParams params) => repository.updateVoucher(params);
}