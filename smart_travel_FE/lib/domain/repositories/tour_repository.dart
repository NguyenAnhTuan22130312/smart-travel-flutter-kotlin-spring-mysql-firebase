import 'package:smart_travel/domain/entities/tour_detail.dart';

abstract class TourRepository {
  Future<TourDetail> getTourDetail(int id);
}
