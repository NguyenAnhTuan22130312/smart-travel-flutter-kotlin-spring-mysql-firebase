import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';


class DeleteVoucherUc extends UseCase<void, int> {
  final VoucherRepository repository;
  DeleteVoucherUc(this.repository);
  @override
  Future<Either<Failure, void>> call(int id) => repository.deleteVoucher(id);
}