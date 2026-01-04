import '../../entities/reviewhtd.dart';
import '../../repositories/reviewhtd_repository.dart';

class GetReviewHtdUseCase {
  final ReviewHtdRepository repository;

  GetReviewHtdUseCase(this.repository);

  Future<List<ReviewHtd>> call({
    required String type,
    required int serviceId,
    int? rating,
    bool? hasImage,
  }) async {
    return await repository.getReviewHtd(
      type: type,
      serviceId: serviceId,
      rating: rating,
      hasImage: hasImage,
    );
  }
}