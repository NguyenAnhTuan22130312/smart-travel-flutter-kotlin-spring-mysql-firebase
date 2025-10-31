import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/province.dart';

abstract class ProvinceRepository{
  ///Lấy danh sách tỉnh thành phổ biến
  Future<Either<Failure, List<ProvinceEntity>>> getAllProvinceIsPopular();

  Future<Either<Failure, ProvinceEntity>> getProvinceDetail(int provinceId);

}