import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/banner.dart';
import 'package:smart_travel/domain/params/banner_create_params.dart';
import 'package:smart_travel/domain/repositories/banner_repository.dart';

class CreateBannerUc extends UseCase<BannerEntity, BannerCreateParams>{
  final BannerRepository bannerRepository;

  CreateBannerUc(this.bannerRepository);

  @override
  Future<Either<Failure, BannerEntity>> call(BannerCreateParams params) {
    return bannerRepository.createBanner(params);
  }

}