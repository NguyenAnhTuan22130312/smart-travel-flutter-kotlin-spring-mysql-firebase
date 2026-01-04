import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/voucher.dart';
import '../../params/voucher_params.dart';
import '../../repositories/voucher_repository.dart';


class CreateVoucherUc extends UseCase<Voucher, VoucherCreateParams> {
  final VoucherRepository repository;
  CreateVoucherUc(this.repository);
  @override
  Future<Either<Failure, Voucher>> call(VoucherCreateParams params) => repository.createVoucher(params);
}