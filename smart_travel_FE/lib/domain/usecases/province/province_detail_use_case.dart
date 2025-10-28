import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';

class ProvinceDetailUseCase extends UseCase<ProvinceEntity, int>{
  final ProvinceRepository provinceRepository;

  ProvinceDetailUseCase(this.provinceRepository);

  @override
  Future<Either<Failure, ProvinceEntity>> call(int provinceId) {
    return provinceRepository.getProvinceDetail(provinceId);
  }

}