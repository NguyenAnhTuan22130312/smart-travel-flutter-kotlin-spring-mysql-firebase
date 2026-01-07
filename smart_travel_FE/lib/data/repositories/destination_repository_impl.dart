import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/data_sources/remote/destination_data_source.dart';
import 'package:smart_travel/data/models/destination/destination_add_request.dart';
import 'package:smart_travel/data/models/destination/destination_upate_request.dart';
import 'package:smart_travel/data/models/destination/destinations-featured-response-modal.dart';
import 'package:smart_travel/data/models/user/user_level_model.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/entities/weather.dart';
import 'package:smart_travel/domain/params/destination_add_params.dart';
import 'package:smart_travel/domain/params/destination_update_params.dart';
import 'package:smart_travel/domain/params/get_weather_params.dart';
import 'package:smart_travel/domain/repositories/destination_repository.dart';

import '../../core/network/network_info.dart';

class DestinationRepositoryImpl extends DestinationRepository {
  final DestinationDataSource destinationDataSource;
  final NetworkInfo networkInfo;
  DestinationRepositoryImpl({required this.destinationDataSource,
  required this.networkInfo});

  @override
  Future<Either<Failure, List<DestinationEntity>>>
  getAllDestinationsFeatured()  async{
    // TODO: implement getAllDestinationsFeatured
    // Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }

    try {
      // Gọi remote data source
      final responseModels = await destinationDataSource.getAllDestinationFeatured();
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
  Future<Either<Failure, List<DestinationEntity>>> getAllDestinations() async {
    // Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final responseModals = await destinationDataSource.getAllDestination();
      final entity = responseModals.map((model) => model.toEntity()).toList();
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
  Future<Either<Failure, List<DestinationEntity>>> filterDestinationsByCategory(
      String category) async {
    // Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final responseModals = await destinationDataSource.filterDestinationsByCategory(category);
      final entity = responseModals.map((model) => model.toEntity()).toList();
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
  Future<Either<Failure, DestinationEntity>> getDestinationDetail(int id) async {
    // Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final responseModals = await destinationDataSource.getDestinationDetail(id);
      return Right(responseModals.toEntity());

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
  Future<Either<Failure, DestinationEntity>> addDestination(DestinationAddParams params)async {
    if(!await networkInfo.isConnected){
      return const Left( NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),);
    }
    try{
      final requestModal = DestinationAddRequest(
        name: params.name,
        description: params.description,
        address: params.address,
        category: params.category,
        entryFee: params.entryFee,
        latitude: params.latitude,
        longitude: params.longitude,
        openingHours: params.openingHours,
        provinceId: params.provinceId,
        isFeatured: params.isFeatured,
      );
      // Chuyển đổi File (dart:io) sang XFile (cross_file) nếu có ảnh
      List<XFile>? imageXFiles;
      if (params.image != null) {
        imageXFiles = params.image!
            .map((file) => XFile(file.path))
            .toList();
      }

      final responseModals = await destinationDataSource.addDestination(requestModal, imageXFiles);
      return Right(responseModals.toEntity());

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
  Future<Either<Failure, DestinationEntity>> updateDestination(DestinationUpdateParams params)async {
    if(!await networkInfo.isConnected){
      return const Left(NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'));

    }
    try{
      final requestModal = DestinationUpdateRequest(
        isFeatured: params.isFeatured,
        longitude: params.longitude,
        openingHours: params.openingHours,
        provinceId: params.provinceId,
        latitude: params.latitude,
        entryFee: params.entryFee,
        category: params.category,
        address: params.address,
        description: params.description,
        name: params.name,
        imageIds: params.imagesToDelete,
      );
      // Chuyển đổi File (dart:io) sang XFile (cross_file) nếu có ảnh
      List<XFile>? imageXFiles;
      if (params.image != null) {
        imageXFiles = params.image!
            .map((file) => XFile(file.path))
            .toList();
      }
      final responseModal = await destinationDataSource.updateDestination(params.destinationId, requestModal, imageXFiles);
      return Right(responseModal.toEntity());
    }on ServerException catch(e){
      return Left(ServerFailure(e.message));
    } on NetworkFailure catch(e){
      return Left(NetworkFailure(e.message));
    }catch(e){
      return Left(
        ServerFailure('Đã xảy ra lỗi không mong muốn: ${e.toString()}'),
      );
    }
  }

  ///XÓA ĐỊA ĐIỂM
  @override
  Future<Either<Failure, String>> deleteDestination(int destinationId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final res = await destinationDataSource.deleteDestination(destinationId);
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không mong muốn: $e'));
    }
  }

  //Lấy thời tiết hiện tại
  @override
  Future<Either<Failure, WeatherEntity>> weather(GetWeatherParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'),
      );
    }
    try {
      final res = await destinationDataSource.weather(params.latitude,params.longitude);
      print("WEATHER");
      print(res);
      return Right(res.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không mong muốn: $e'));
    }
  }

  @override
  Future<Either<Failure, UserLevelModel>> completeVoice(int id) async {
    try {
      final result = await destinationDataSource.completeVoice(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
