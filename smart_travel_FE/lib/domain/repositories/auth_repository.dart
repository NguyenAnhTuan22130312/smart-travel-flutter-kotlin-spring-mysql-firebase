import 'package:dartz/dartz.dart';
import 'package:smart_travel/domain/entities/auth.dart';
import 'package:smart_travel/domain/params/RegisterParams.dart';
import 'package:smart_travel/domain/params/login_params.dart';
import 'package:smart_travel/domain/params/refresh_token_params.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> register(RegisterParams request);
  Future<Either<Failure, AuthEntity>> login(LoginParams  request );
  Future<Either<Failure, AuthEntity>> refreshToken(RefreshTokenParams refreshToken);
  Future<Either<Failure, String>> forgotPassword(String email );
  Future<Either<Failure, AuthEntity>> googleLogin();
  Future<Either<Failure, AuthEntity>> facebookLogin();
}