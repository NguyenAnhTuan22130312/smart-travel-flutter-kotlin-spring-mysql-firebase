import 'package:dartz/dartz.dart';
import 'package:smart_travel/core/error/failures.dart';
import 'package:smart_travel/core/usecases/usecase.dart';
import 'package:smart_travel/domain/entities/hotel_page.dart';
import 'package:smart_travel/domain/repositories/hotel_repository.dart';

class GetHotelsUseCase extends UseCase<HotelsPage, GetHotelsParams> {
  final HotelRepository hotelRepository;

  GetHotelsUseCase(this.hotelRepository);

  @override
  Future<Either<Failure, HotelsPage>> call(GetHotelsParams params) {
    return hotelRepository.getHotels(
      destinationId: params.destinationId,
      keyword: params.keyword,
      minStars: params.minStars,
      maxStars: params.maxStars,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      city: params.city,
      page: params.page,
      size: params.size,
      sortBy: params.sortBy,
      sortDir: params.sortDir,
    );
  }
}

class GetHotelsParams {
  final int? destinationId;
  final String? keyword;
  final int? minStars;
  final int? maxStars;
  final double? minPrice;
  final double? maxPrice;
  final String? city;
  final int page;
  final int size;
  final String? sortBy;
  final String? sortDir;

  GetHotelsParams({
    this.destinationId,
    this.keyword,
    this.minStars,
    this.maxStars,
    this.minPrice,
    this.maxPrice,
    this.city,
    this.page = 0,
    this.size = 10,
    this.sortBy = 'pricePerNight',
    this.sortDir = 'asc',
  });
}
