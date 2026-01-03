import 'package:image_picker/image_picker.dart';

abstract class ReviewRepository {
  Future<void> submitReview({
    required int rating,
    String? comment,
    required String invoiceNumber,
    required List<XFile> images
  });
}