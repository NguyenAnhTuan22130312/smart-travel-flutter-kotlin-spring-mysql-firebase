import 'package:smart_travel/domain/repositories/tour_repository.dart';
import 'package:smart_travel/data/models/tour/admin_tour_model.dart';

class GetAdminTours {
  final TourRepository repository;

  GetAdminTours(this.repository);

  Future<List<AdminTourModel>> call() {
    return repository.getTours();
  }
}
