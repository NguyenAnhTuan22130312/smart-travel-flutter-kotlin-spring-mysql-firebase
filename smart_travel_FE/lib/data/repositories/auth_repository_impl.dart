import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/data/data_sources/remote/auth_remote_datasource.dart';
import 'package:smart_travel/data/models/auth/login_request_modal.dart';
import 'package:smart_travel/data/models/auth/login_response_modal.dart';
import 'package:smart_travel/data/models/auth/register_request_model.dart';
import 'package:smart_travel/data/models/auth/register_response_model.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;
  final NetworkInfo networkInfo;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
    required this.localDataSource,
  });


  @override
  Future<Either<Failure, RegisterResponseModel>> register(
      RegisterRequestModel request) async {
    // Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
          NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'));
    }

    try {
      // Gọi remote data source
      final result = await dataSource.register(request);
      // Trả về kết quả thành công
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không mong muốn: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LoginResponseModal>> login(LoginRequestModal request) async {
    // TODO: implement login
    if(!await networkInfo.isConnected){
      return const Left(NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'));
    }
    try{
      // Gọi remote data source
      final result = await dataSource.login(request);
      // Lưu token sau khi login thành công
      await localDataSource.saveToken(result.token);
      await localDataSource.saveRefreshToken(result.refreshToken);
      await localDataSource.saveRole(result.role);
      return  Right(result);
    } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
    } catch (e) {
    return Left(ServerFailure('Đã xảy ra lỗi không mong muốn: ${e.toString()}'));
    }
  }
}