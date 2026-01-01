
abstract class CancelEvent {}

class SubmitCancelRequest extends CancelEvent {
  final int bookingId;
  final String reason;

  SubmitCancelRequest({required this.bookingId, required this.reason});
}