import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/network/network_info.dart';
import 'package:smart_travel/data/data_sources/remote/voucher_data_source.dart';
import 'package:smart_travel/data/models/voucher/voucher_create_request.dart';
import 'package:smart_travel/data/models/voucher/voucher_update_request.dart';
import 'package:smart_travel/domain/entities/voucher.dart';
import 'package:smart_travel/domain/params/voucher_params.dart';
import 'package:smart_travel/domain/repositories/voucher_repository.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherDataSource voucherDataSource;
  final NetworkInfo networkInfo;

  VoucherRepositoryImpl({required this.voucherDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<Voucher>>> getAllVouchers() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
    try {
      final models = await voucherDataSource.getAllVoucher();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Voucher>> createVoucher(VoucherCreateParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
    try {
      // Map Params -> Request Model
      final request = VoucherCreateRequest(
        code: params.code,
        discountAmount: params.discountAmount,
        expiryDate: params.expiryDate.toIso8601String(),
        isActive: params.isActive,
        usageLimit: params.usageLimit,
      );

      final model = await voucherDataSource.createVoucher(request);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Voucher>> updateVoucher(VoucherUpdateParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
    try {
      final request = VoucherUpdateRequest(
        id: params.id,
        code: params.code,
        discountAmount: params.discountAmount,
        expiryDate: params.expiryDate.toIso8601String(),
        isActive: params.isActive,
        usageLimit: params.usageLimit,
      );

      final model = await voucherDataSource.updateVoucher(request);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVoucher(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Không có kết nối internet'));
    }
    try {
      await voucherDataSource.deleteVoucher(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}