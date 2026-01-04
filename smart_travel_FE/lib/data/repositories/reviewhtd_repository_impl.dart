
import '../../../domain/entities/reviewhtd.dart';
import '../../../domain/repositories/reviewhtd_repository.dart';
import '../data_sources/remote/reviewhtd_remote_data_source.dart';

class ReviewHtdRepositoryImpl implements ReviewHtdRepository {
  final ReviewHtdRemoteDataSource remoteDataSource;

  ReviewHtdRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ReviewHtd>> getReviewHtd({
    required String type,
    required int serviceId,
    int? rating,
    bool? hasImage,
  }) async {
    final models = await remoteDataSource.getReviewHtd(
      type: type,
      serviceId: serviceId,
      rating: rating,
      hasImage: hasImage,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}