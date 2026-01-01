
import '../../../domain/entities/invoice.dart';

abstract class RefundState {}

class RefundInitial extends RefundState {}

class RefundLoading extends RefundState {}

class RefundLoaded extends RefundState {
  final List<Invoice> invoices;
  RefundLoaded(this.invoices);
}

class RefundError extends RefundState {
  final String message;
  RefundError(this.message);
}