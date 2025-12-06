import 'package:smart_travel/domain/entities/tour_detail.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';

class GetTourDetailUseCase {
  final TourRepository repo;

  GetTourDetailUseCase(this.repo);

  Future<TourDetail> call(int id) {
    return repo.getTourDetail(id);
  }
}
