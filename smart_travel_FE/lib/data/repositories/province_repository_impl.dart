import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/remote/province_data_source.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/province/province_add_request.dart';
import 'package:smart_travel/data/models/province/province_update_request.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/params/province_add_params.dart';
import 'package:smart_travel/domain/params/province_update_params.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';

class ProvinceRepositoryImpl implements ProvinceRepository {
  final ProvinceDataSource provinceDataSource;
  final NetworkInfo networkInfo;

  ProvinceRepositoryImpl({
    required this.provinceDataSource,
    required this.networkInfo,
  });

  //Lấy danh sách tỉnh thành
  @override
  Future<Either<Failure, List<ProvinceEntity>>>
  getAllProvinceIsPopular() async {
    // TODO: implement getAllProvinceIsPopular

    //Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final responseModal = await provinceDataSource.getAllProvince();
      final entity = responseModal.map((modal) => modal.toEntity()).toList();
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không mong muốn: $e'));
    }
  }

  /// xem chi tiết tỉnh thành
  @override
  Future<Either<Failure, ProvinceEntity>> getProvinceDetail(
    int provinceId,
  ) async {
    //Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final responseModal = await provinceDataSource.getProvinceDetail(
        provinceId,
      );
      final entity = responseModal.toEntity();
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không mong muốn: $e'));
    }
  }

  ///Theem mới tỉnh thành
  @override
  Future<Either<Failure, ProvinceEntity>> addProvince(
    ProvinceAddParams param,
  ) async {
    //Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }

    try {
      final requestModal = ProvinceAddRequest(
        code: param.code,
        isPopular: param.isPopular,
        name: param.name,
        region: param.region,
        description: param.description,
      );
      // Chuyển đổi File (dart:io) sang XFile (cross_file) nếu có ảnh
      XFile? imageXFile;
      if (param.image != null) {
        imageXFile = XFile(param.image!.path);
      }
      final responseModal = await provinceDataSource.addProvince(
        requestModal,
        imageXFile,
      );
      print("RES" + responseModal.toString());
      final entity = responseModal.toEntity();
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không mong muốn: $e'));
    }
  }

  ///Cập nhật tỉnh thành
  @override
  Future<Either<Failure, ProvinceEntity>> updateProvince(
      ProvinceUpdateParams param,
      ) async {
    //Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }

    try {
      final requestModal = ProvinceUpdateRequest(
        code: param.code,
        isPopular: param.isPopular,
        name: param.name,
        region: param.region,
        description: param.description,
      );
      // Chuyển đổi File (dart:io) sang XFile (cross_file) nếu có ảnh
      XFile? imageXFile;
      if (param.image != null) {
        imageXFile = XFile(param.image!.path);
      }
      final responseModal = await provinceDataSource.updateProvince(
        param.provinceId,
        requestModal,
        imageXFile,
      );
      final entity = responseModal.toEntity();
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không mong muốn: $e'));
    }
  }

  ///XÓA TỈNH THÀNH
  @override
  Future<Either<Failure, String>> deleteProvince(int provinceId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final res = await provinceDataSource.deleteProvince(provinceId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không mong muốn: $e'));
    }
  }
}
