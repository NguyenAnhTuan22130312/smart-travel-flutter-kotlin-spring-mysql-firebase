import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/banner.dart';
import 'package:smart_travel/domain/params/banner_update_params.dart';
import 'package:smart_travel/domain/repositories/banner_repository.dart';

class UpdateBannerUc extends UseCase<BannerEntity, BannerUpdateParams>{
  final BannerRepository bannerRepository;

  UpdateBannerUc(this.bannerRepository);

  @override
  Future<Either<Failure, BannerEntity>> call(BannerUpdateParams params) {
    return bannerRepository.updateBanner(params);
  }

}