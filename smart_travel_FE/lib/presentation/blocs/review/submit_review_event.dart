import 'package:image_picker/image_picker.dart';

abstract class SubmitReviewEvent {}

class SubmitReview extends SubmitReviewEvent {
  final int rating;
  final String? comment;
  final String invoiceNumber;
  final List<XFile> images;

  SubmitReview({
    required this.rating,
    this.comment,
    required this.invoiceNumber,
    required this.images,
  });
}
