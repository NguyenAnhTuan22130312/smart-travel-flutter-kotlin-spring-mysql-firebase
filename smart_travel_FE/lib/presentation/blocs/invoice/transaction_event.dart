abstract class TransactionEvent {}

class LoadTransactionHistory extends TransactionEvent {
  final String? type; // null hoặc "HOTEL", "TOUR", "all"
  final String? status; // null hoặc "ACTIVE", "COMPLETED", "CANCELED", "REFUNDED", "PENDING_REFUND", "CHECKED"

  LoadTransactionHistory({this.type, this.status});
}