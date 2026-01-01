import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';

class CreateAdminTourUseCase {
  final TourRepository repository;

  CreateAdminTourUseCase(this.repository);

  Future<AdminTourModel> call(Map<String, dynamic> body) {
    return repository.createTour(body);
  }
}
