import 'package:smart_travel/domain/entities/tour.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';

class FilterToursUseCase {
  final TourRepository repository;

  FilterToursUseCase(this.repository);

  Future<dynamic> call(TourFilterParams params) async {
    return await repository.filterTours(params);
  }
}
