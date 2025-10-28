import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/remote/province_data_source.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/domain/repositories/province_repository.dart';

class ProvinceRepositoryImpl implements ProvinceRepository {
  final ProvinceDataSource provinceDataSource;
  final NetworkInfo networkInfo;

  ProvinceRepositoryImpl({required this.provinceDataSource, required this.networkInfo});
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
      return Left(
        ServerFailure('Đã xảy ra lỗi không mong muốn: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ProvinceEntity>> getProvinceDetail(int provinceId) async {
    //Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final responseModal = await provinceDataSource.getProvinceDetail(provinceId);
      final entity = responseModal.toEntity();
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Đã xảy ra lỗi không mong muốn: ${e.toString()}'),
      );
    }
  }
}
