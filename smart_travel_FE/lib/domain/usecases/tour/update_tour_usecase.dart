import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';

class UpdateAdminTourUseCase {
  final TourRepository repository;

  UpdateAdminTourUseCase(this.repository);

  Future<void> call(int id, Map<String, dynamic> body) {
    return repository.updateTour(id, body);
  }
}
