import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';
// SỬA: Import các file UseCase và DTO
import 'package:smart_travel/data/repositories/payment_repository_impl.dart';
import 'package:smart_travel/domain/usecases/payment/process_payment_usecase.dart';
import 'package:smart_travel/domain/usecases/payment/confirm_cash_usecase.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  // SỬA: Bỏ comment và khai báo
  final ProcessPaymentUseCase processPaymentUseCase;
  final ConfirmCashBookingUseCase confirmCashBookingUseCase;

  // SỬA: Cập nhật hàm khởi tạo (Constructor)
  PaymentBloc({
    required this.processPaymentUseCase,
    required this.confirmCashBookingUseCase,
  }) : super(PaymentInitial()) {
    on<ProcessPaymentSubmitted>(_onProcessPaymentSubmitted);
    on<ConfirmCashPayment>(_onConfirmCashPayment);
  }

  Future<void> _onProcessPaymentSubmitted(
      ProcessPaymentSubmitted event,
      Emitter<PaymentState> emit,
      ) async {
    emit(PaymentLoading());

    // SỬA: Bỏ logic giả (mock) và gọi API thật
    final request = PaymentApiRequest(
      bookingId: event.bookingId,
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    );
    // Gọi UseCase
    final result = await processPaymentUseCase(request);

    result.fold(
          (failure) => emit(PaymentFailure(failure.message)), // Lỗi
          (paymentUrl) => emit(PaymentSuccess(paymentUrl)), // Thành công
    );
  }

  // SỬA: HÀM Xử lý thanh toán tiền mặt
  Future<void> _onConfirmCashPayment(
      ConfirmCashPayment event,
      Emitter<PaymentState> emit,
      ) async {
    emit(PaymentLoading());

    // SỬA: Bỏ logic giả (mock) và gọi API thật
    final request = CashApiRequest(
      bookingId: event.bookingId,
      amount: event.amount,
    );

    // Gọi UseCase
    final result = await confirmCashBookingUseCase(request);

    result.fold(
          (failure) => emit(PaymentFailure(failure.message)), // Lỗi
          (_) => emit(PaymentCashSuccess()), // Thành công
    );
  }
}