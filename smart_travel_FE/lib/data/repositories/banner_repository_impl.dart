import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/remote/banner_data_source.dart';
import 'package:smart_travel/domain/entities/banner.dart';
import 'package:smart_travel/domain/params/banner_create_params.dart';
import 'package:smart_travel/domain/params/banner_update_params.dart';
import 'package:smart_travel/domain/repositories/banner_repository.dart';

class BannerRepositoryImpl implements BannerRepository{
  final BannerDataSource bannerDataSource;
  final NetworkInfo networkInfo;


  BannerRepositoryImpl({required this.bannerDataSource, required this.networkInfo});
  @override
  Future<Either<Failure, List<BannerEntity>>> getAllBanners()async {
    if(!await networkInfo.isConnected){
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      // Gọi remote data source
      final responseModels = await bannerDataSource.getAllBanner();
      final entity = responseModels.map((model) => model.toEntity()).toList();
      // Trả về kết quả thành công
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
  Future<Either<Failure, BannerEntity>> createBanner(BannerCreateParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }

    try {
      // Chuyển từ Params sang Request DTO
      final request = params.toRequest();

      final model = await bannerDataSource.addBanner(request);

      // Trả về Entity sau khi map từ Model
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BannerEntity>> updateBanner(BannerUpdateParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }

    try {
      // Chuyển từ Params sang Request DTO
      final request = params.toRequest();

      final model = await bannerDataSource.updateBanner(request);

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBanner(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet.'));
    }

    try {
      await bannerDataSource.deleteBanner(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: ${e.toString()}'));
    }
  }

}