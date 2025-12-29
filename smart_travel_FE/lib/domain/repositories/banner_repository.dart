import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/domain/entities/banner.dart';
import 'package:smart_travel/domain/params/banner_create_params.dart';
import 'package:smart_travel/domain/params/banner_update_params.dart';

abstract class BannerRepository{
  Future<Either<Failure, List<BannerEntity>>> getAllBanners();
  Future<Either<Failure, BannerEntity>> updateBanner(BannerUpdateParams params);
  Future<Either<Failure, BannerEntity>> createBanner(BannerCreateParams params);
  Future<Either<Failure, void>> deleteBanner(int id);
}