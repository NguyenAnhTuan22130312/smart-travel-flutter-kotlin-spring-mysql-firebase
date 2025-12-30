import 'package:smart_travel/domain/entities/tour_detail.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';

class GetTourDetailUseCase {
  final TourRepository repository;

  GetTourDetailUseCase(this.repository);

  Future<TourDetail> call(int id) {
    return repository.getTourDetail(id);
  }
}
