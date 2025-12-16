import 'package:smart_travel/domain/entities/tour_detail.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';
import 'package:smart_travel/domain/entities/tour.dart';

abstract class TourRepository {
  Future<TourDetail> getTourDetail(int id);
  Future<List<Tour>> filterTours(TourFilterParams params);
}
