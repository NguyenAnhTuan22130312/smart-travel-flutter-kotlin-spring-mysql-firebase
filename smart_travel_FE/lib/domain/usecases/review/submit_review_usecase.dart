import 'package:image_picker/image_picker.dart';

import '../../repositories/review_repository.dart';


class SubmitReviewUseCase {
  final ReviewRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<void> call({
    required int rating,
    String? comment,
    required String invoiceNumber,
    required List<XFile> images,
  }) async {
    return await repository.submitReview(
      rating: rating,
      comment: comment,
      invoiceNumber: invoiceNumber,
      images: images
    );
  }
}