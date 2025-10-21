import 'package:equatable/equatable.dart';


abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

// Event khi người dùng nhấn nút "Xác nhận thanh toán"
class ProcessPaymentSubmitted extends PaymentEvent {
  final String bookingId;
  final double amount;
  final String paymentMethod; // Ví dụ: 'VNPAY', 'MOMO'

  const ProcessPaymentSubmitted({
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [bookingId, amount, paymentMethod];
}