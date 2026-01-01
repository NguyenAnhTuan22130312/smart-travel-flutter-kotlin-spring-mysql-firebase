import 'package:smart_travel/domain/repositories/tour_repository.dart';

class DeleteAdminTourUseCase {
  final TourRepository repository;

  DeleteAdminTourUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteTour(id);
  }
}
