import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';
// Import các file mới
import 'package:smart_travel/data/repositories/payment_repository_impl.dart';
import 'package:smart_travel/domain/usecases/payment/process_payment_usecase.dart';
import 'package:smart_travel/domain/usecases/payment/confirm_cash_usecase.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  // SỬA: Bỏ comment
  final ProcessPaymentUseCase processPaymentUseCase;
  final ConfirmCashBookingUseCase confirmCashBookingUseCase;

  // SỬA: Inject UseCases
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

    // --- GỌI API THẬT ---
    final request = PaymentApiRequest(
      bookingId: event.bookingId,
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    );
    // Gọi UseCase
    final result = await processPaymentUseCase(request);

    result.fold(
          (failure) => emit(PaymentFailure(failure.message)), // Lỗi (1007 hoặc 1000)
          (paymentUrl) => emit(PaymentSuccess(paymentUrl)), // Thành công
    );
  }

  Future<void> _onConfirmCashPayment(
      ConfirmCashPayment event,
      Emitter<PaymentState> emit,
      ) async {
    emit(PaymentLoading());

    // --- GỌI API THẬT ---
    final request = CashApiRequest(
      bookingId: event.bookingId,
      amount: event.amount,
    );

    final result = await confirmCashBookingUseCase(request);

    result.fold(
          (failure) => emit(PaymentFailure(failure.message)),
          (_) => emit(PaymentCashSuccess()), // Thành công
    );
  }
}