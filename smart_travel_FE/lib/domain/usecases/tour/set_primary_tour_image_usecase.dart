import 'package:smart_travel/domain/repositories/tour_repository.dart';

class SetPrimaryTourImageUseCase {
  final TourRepository repository;

  SetPrimaryTourImageUseCase(this.repository);

  Future<void> call(int imageId) {
    return repository.setPrimaryImage(imageId);
  }
}
