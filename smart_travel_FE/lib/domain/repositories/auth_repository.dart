import 'package:dartz/dartz.dart';
import 'package:smart_travel/data/models/auth/login_request_modal.dart';
import 'package:smart_travel/data/models/auth/login_response_modal.dart';
import 'package:smart_travel/data/models/auth/register_request_model.dart';
import 'package:smart_travel/data/models/auth/register_response_model.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, RegisterResponseModel>> register(RegisterRequestModel request);
  Future<Either<Failure, LoginResponseModal>> login(LoginRequestModal request );
}