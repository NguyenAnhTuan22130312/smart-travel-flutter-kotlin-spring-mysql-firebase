import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/review_event.dart';
import 'package:smart_travel/presentation/blocs/invoice/review_state.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/usecases/invoice/get_reviewable_invoices_usecase.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetReviewableInvoicesUseCase getReviewableInvoicesUseCase;

  ReviewBloc(this.getReviewableInvoicesUseCase) : super(ReviewInitial()) {
    on<LoadReviewableInvoices>((event, emit) async {
      emit(ReviewLoading());
      try {
        final invoices = await getReviewableInvoicesUseCase();
        emit(ReviewLoaded(invoices));
      } catch (e) {
        emit(ReviewError(e.toString()));
      }
    });
  }
}