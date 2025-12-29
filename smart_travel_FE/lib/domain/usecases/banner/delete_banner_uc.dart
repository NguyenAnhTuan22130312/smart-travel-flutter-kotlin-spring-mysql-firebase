import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/banner.dart';
import 'package:smart_travel/domain/params/banner_update_params.dart';
import 'package:smart_travel/domain/repositories/banner_repository.dart';

class DeleteBannerUc extends UseCase<void, int>{
  final BannerRepository bannerRepository;

  DeleteBannerUc(this.bannerRepository);

  @override
  Future<Either<Failure, void>> call(int id) {
    return bannerRepository.deleteBanner(id);
  }

}