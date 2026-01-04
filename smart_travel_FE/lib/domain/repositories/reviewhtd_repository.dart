
import '../entities/reviewhtd.dart';

abstract class ReviewHtdRepository {
  Future<List<ReviewHtd>> getReviewHtd({
    required String type,
    required int serviceId,
    int? rating,
    bool? hasImage,
  });
}