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
import 'package:smart_travel/domain/entities/auth.dart';
import 'package:smart_travel/domain/params/LoginParams.dart';
import 'package:smart_travel/domain/params/RegisterParams.dart';
import 'package:smart_travel/domain/repositories/auth_repository.dart';
import 'package:smart_travel/domain/usecases/auth/login_use_case.dart';

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
  Future<Either<Failure, AuthEntity>> register(
      RegisterParams params) async {
    // Kiểm tra kết nối mạng
    if (!await networkInfo.isConnected) {
      return const Left(
          NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'));
    }

    try {
      final requestModal = RegisterRequestModel(
          fullName: params.fullName,
          email: params.email,
          phone: params.phone,
          password: params.password,
          confirmPassword: params.confirmPassword
      );
      // Gọi remote data source
      final responseModel = await dataSource.register(requestModal);
      final entity = responseModel.toEntity();
      // Trả về kết quả thành công
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không mong muốn: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(LoginParams params) async {
    // TODO: implement login
    if(!await networkInfo.isConnected){
      return const Left(NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'));
    }
    try{
      // Chuyển Domain → Data
      final requestModel = LoginRequestModal(
        email: params.email,
        password: params.password,
      );

      // Gọi remote data source
      final responseModel = await dataSource.login(requestModel);

      // Lưu token sau khi login thành công
      await localDataSource.saveToken(responseModel.token);
      await localDataSource.saveRefreshToken(responseModel.refreshToken);
      await localDataSource.saveRole(responseModel.role);
      await localDataSource.saveFullName(responseModel.fullName);
      final entity = responseModel.toEntity();

      return  Right(entity);
    } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
    } catch (e) {
    return Left(ServerFailure('Đã xảy ra lỗi không mong muốn: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async{
    if(!await networkInfo.isConnected){
      return const Left(NetworkFailure('Không có kết nối internet. Vui lòng kiểm tra lại.'));
    }
    try{
      // Gọi remote data source
      final result = await dataSource.forgotPassword(email);
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