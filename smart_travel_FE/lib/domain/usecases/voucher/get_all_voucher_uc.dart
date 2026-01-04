import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetAllVoucherUc extends UseCase<List<Voucher>, NoParams> {
  final VoucherRepository repository;
  GetAllVoucherUc(this.repository);
  @override
  Future<Either<Failure, List<Voucher>>> call(NoParams params) => repository.getAllVouchers();
}
