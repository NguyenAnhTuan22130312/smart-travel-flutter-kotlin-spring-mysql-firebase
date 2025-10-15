import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/data/data_sources/remote/destination_data_source.dart';
import 'package:smart_travel/data/models/auth/destinations-featured-response-modal.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
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
}
