import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/review/get_reviewhtd_usecase.dart';
import 'reviewhtd_event.dart';
import 'reviewhtd_state.dart';

class ReviewHtdBloc extends Bloc<ReviewHtdEvent, ReviewHtdState> {
  final GetReviewHtdUseCase getReviewHtdUseCase;

  ReviewHtdBloc(this.getReviewHtdUseCase) : super(ReviewHtdInitial()) {
    on<LoadReviewHtd>((event, emit) async {
      emit(ReviewHtdLoading());
      try {
        final reviews = await getReviewHtdUseCase(
          type: event.type,
          serviceId: event.serviceId,
          rating: event.rating,
          hasImage: event.hasImage,
        );
        emit(ReviewHtdLoaded(reviews));
      } catch (e) {
        emit(ReviewHtdError(e.toString()));
      }
    });
  }
}