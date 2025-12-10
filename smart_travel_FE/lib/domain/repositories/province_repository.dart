import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/params/province_add_params.dart';
import 'package:smart_travel/domain/params/province_update_params.dart';

abstract class ProvinceRepository{
  ///Lấy danh sách tỉnh thành phổ biến
  Future<Either<Failure, List<ProvinceEntity>>> getAllProvinceIsPopular();

  ///Xem chi tiết tỉnh thành
  Future<Either<Failure, ProvinceEntity>> getProvinceDetail(int provinceId);

  ///Thêm mới tỉnh thành
  Future<Either<Failure, ProvinceEntity>> addProvince(ProvinceAddParams param);

  ///Cập nhật tỉnh thành
  Future<Either<Failure, ProvinceEntity>> updateProvince(ProvinceUpdateParams param);

  ///Xóa tỉnh thành
  Future<Either<Failure, String>> deleteProvince(int provinceId);

}