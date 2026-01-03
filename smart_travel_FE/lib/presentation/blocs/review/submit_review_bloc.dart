import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/presentation/blocs/review/submit_review_event.dart';
import 'package:smart_travel/presentation/blocs/review/submit_review_state.dart';
import '../../../domain/usecases/review/submit_review_usecase.dart';




class SubmitReviewBloc extends Bloc<SubmitReviewEvent, SubmitReviewState> {
  final SubmitReviewUseCase submitUseCase;

  SubmitReviewBloc(this.submitUseCase) : super(SubmitReviewInitial()) {
    on<SubmitReview>((event, emit) async {
      emit(SubmitReviewLoading());
      try {
        await submitUseCase(
          rating: event.rating,
          comment: event.comment,
          invoiceNumber: event.invoiceNumber,
          images: event.images
        );
        emit(SubmitReviewSuccess());
      } catch (e) {
        emit(SubmitReviewError(e.toString()));
      }
    });
  }
}