import 'package:smart_travel/domain/repositories/tour_repository.dart';

class DeleteTourImageUseCase {
  final TourRepository repository;

  DeleteTourImageUseCase(this.repository);

  Future<void> call(int imageId) {
    return repository.deleteTourImage(imageId);
  }
}
