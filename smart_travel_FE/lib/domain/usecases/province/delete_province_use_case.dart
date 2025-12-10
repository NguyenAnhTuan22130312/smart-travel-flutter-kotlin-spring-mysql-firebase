import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';

class DeleteProvinceUseCase extends UseCase<String, int>{

  final ProvinceRepository provinceRepository;

  DeleteProvinceUseCase(this.provinceRepository);
  @override
  Future<Either<Failure, String>> call(int provinceId) {
   return provinceRepository.deleteProvince(provinceId);
  }
}