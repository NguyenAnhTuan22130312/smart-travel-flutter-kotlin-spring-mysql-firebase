
abstract class CancelState {}

class CancelInitial extends CancelState {}

class CancelLoading extends CancelState {}

class CancelSuccess extends CancelState {}

class CancelError extends CancelState {
  final String message;
  CancelError(this.message);
}