import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/params/province_add_params.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';

class AddProvinceUseCase extends UseCase<ProvinceEntity, ProvinceAddParams>{
  final ProvinceRepository provinceRepository;

  AddProvinceUseCase(this.provinceRepository);
  @override
  Future<Either<Failure, ProvinceEntity>> call(ProvinceAddParams param) {
    return provinceRepository.addProvince(param);
  }

}