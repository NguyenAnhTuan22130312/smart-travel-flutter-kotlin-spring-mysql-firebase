import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/params/province_update_params.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';

class UpdateProvinceUseCase extends UseCase<ProvinceEntity, ProvinceUpdateParams> {
  final ProvinceRepository provinceRepository;

  UpdateProvinceUseCase(this.provinceRepository);

  @override
  Future<Either<Failure, ProvinceEntity>> call( ProvinceUpdateParams params) {
    return provinceRepository.updateProvince(params);
  }

}