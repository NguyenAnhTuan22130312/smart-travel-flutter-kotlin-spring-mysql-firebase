import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/banner.dart';
import 'package:smart_travel/domain/repositories/banner_repository.dart';

class GetAllBannerUseCase extends UseCase<List<BannerEntity>, NoParams>{
  final BannerRepository bannerRepository;

  GetAllBannerUseCase(this.bannerRepository);

  @override
  Future<Either<Failure, List<BannerEntity>>> call(NoParams params) {
    return bannerRepository.getAllBanners();
  }

}