import 'package:image_picker/image_picker.dart';

import '../../domain/repositories/review_repository.dart';
import '../data_sources/remote/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> submitReview({
    required int rating,
    String? comment,
    required String invoiceNumber,
    required List<XFile> images
  }) async {
    await remoteDataSource.submitReview(
      rating: rating,
      comment: comment,
      invoiceNumber: invoiceNumber,
      images: images
    );
  }
}