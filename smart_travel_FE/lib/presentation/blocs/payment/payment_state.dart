import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

// State cho VNPay/MoMo thành công
class PaymentSuccess extends PaymentState {
  final String paymentUrl;
  const PaymentSuccess(this.paymentUrl);
  @override
  List<Object?> get props => [paymentUrl];
}

// THÊM MỚI: State cho thanh toán tiền mặt thành công
class PaymentCashSuccess extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String message;
  const PaymentFailure(this.message);
  @override
  List<Object?> get props => [message];
}