import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

// State khi gọi API thành công và nhận được URL
class PaymentSuccess extends PaymentState {
  final String paymentUrl;

  const PaymentSuccess(this.paymentUrl);

  @override
  List<Object?> get props => [paymentUrl];
}

// State khi có lỗi
class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}