import 'package:smart_travel/domain/repositories/tour_repository.dart';
import 'package:smart_travel/data/models/tour/tour_detail_model.dart';

class GetAllToursUseCase {
  final TourRepository repository;
  GetAllToursUseCase(this.repository);

  Future<List<TourModel>> call() => repository.getAllTours();
}
