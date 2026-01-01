import '../../../domain/entities/invoice.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Invoice> invoices;
  SearchLoaded(this.invoices);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
