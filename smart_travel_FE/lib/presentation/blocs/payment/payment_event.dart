import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

// Event cho các cổng online (VNPay, MoMo)
class ProcessPaymentSubmitted extends PaymentEvent {
  final String bookingId;
  final double amount;
  final String paymentMethod; // 'VNPAY', 'MOMO'

  const ProcessPaymentSubmitted({
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [bookingId, amount, paymentMethod];
}

// THÊM MỚI: Event cho thanh toán tiền mặt/trực tiếp
class ConfirmCashPayment extends PaymentEvent {
  final String bookingId;
  final double amount;

  const ConfirmCashPayment({
    required this.bookingId,
    required this.amount,
  });

  @override
  List<Object?> get props => [bookingId, amount];
}