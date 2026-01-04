import 'package:smart_travel/domain/repositories/tour_repository.dart';
import 'package:smart_travel/data/models/tour/admin_tour_model.dart';

class GetAdminTours {
  final TourRepository repository;

  GetAdminTours(this.repository);

  Future<dynamic> call({int page = 0, int size = 10}) {
    return repository.getTours(page: page, size: size);
  }
}
