import '../../../domain/entities/invoice.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<Invoice> invoices;
  ReviewLoaded(this.invoices);
}

class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
}
