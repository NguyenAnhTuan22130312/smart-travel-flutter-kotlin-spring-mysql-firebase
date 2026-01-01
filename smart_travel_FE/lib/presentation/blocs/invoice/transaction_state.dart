import '../../../domain/entities/invoice.dart';

abstract class TransactionState {}
class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Invoice> invoices;
  TransactionLoaded(this.invoices);
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}
