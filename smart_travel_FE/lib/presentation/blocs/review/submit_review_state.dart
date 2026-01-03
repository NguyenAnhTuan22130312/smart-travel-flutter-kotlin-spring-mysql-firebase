abstract class SubmitReviewState {}

class SubmitReviewInitial extends SubmitReviewState {}

class SubmitReviewLoading extends SubmitReviewState {}

class SubmitReviewSuccess extends SubmitReviewState {}

class SubmitReviewError extends SubmitReviewState {
  final String message;
  SubmitReviewError(this.message);
}