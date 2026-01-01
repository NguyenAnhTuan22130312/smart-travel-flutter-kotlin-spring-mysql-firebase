import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
import 'package:smart_travel/domain/entities/tour_detail.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';

class GetAdminTourDetailUseCase {
  final TourRepository repository;

  GetAdminTourDetailUseCase(this.repository);

  Future<AdminTourModel> call(int id) {
    return repository.getToursDetail(id);
  }
}
