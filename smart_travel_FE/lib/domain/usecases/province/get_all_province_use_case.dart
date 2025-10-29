import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';

class GetAllProvinceUseCase extends UseCase<List<ProvinceEntity>, NoParams> {
  final ProvinceRepository provinceRepository;

  GetAllProvinceUseCase( this.provinceRepository);
  @override
  Future<Either<Failure, List<ProvinceEntity>>> call(NoParams params) {
    // TODO: implement call
    return provinceRepository.getAllProvinceIsPopular();
  }

}