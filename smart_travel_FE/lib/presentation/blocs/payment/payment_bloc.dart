import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';
// TODO: Import UseCase

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  // TODO:
  // final ProcessPaymentUseCase processPaymentUseCase;
  // final ConfirmCashBookingUseCase confirmCashBookingUseCase;

  PaymentBloc() : super(PaymentInitial()) {
    on<ProcessPaymentSubmitted>(_onProcessPaymentSubmitted);
    // THÊM MỚI:
    on<ConfirmCashPayment>(_onConfirmCashPayment);
  }

  Future<void> _onProcessPaymentSubmitted(
      ProcessPaymentSubmitted event,
      Emitter<PaymentState> emit,
      ) async {
    emit(PaymentLoading());
    await Future.delayed(Duration(seconds: 2));

    // Giả lập API trả về URL
    if (event.paymentMethod == 'VNPAY') {
      emit(PaymentSuccess("https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?mock=true"));
    } else if (event.paymentMethod == 'MOMO') {
      emit(PaymentSuccess("https://test-payment.momo.vn/gw_payment/payment/qr?mock=true"));
    } else {
      emit(PaymentFailure("Phương thức không được hỗ trợ"));
    }
  }

  // HÀM MỚI: Xử lý thanh toán tiền mặt
  Future<void> _onConfirmCashPayment(
      ConfirmCashPayment event,
      Emitter<PaymentState> emit,
      ) async {
    emit(PaymentLoading());

    // Giả lập gọi API để cập nhật trạng thái đơn hàng
    await Future.delayed(Duration(seconds: 1));

    // TODO: Gọi confirmCashBookingUseCase
    // final result = await confirmCashBookingUseCase(event.bookingId);
    // result.fold(
    //   (failure) => emit(PaymentFailure(failure.message)),
    //   (_) => emit(PaymentCashSuccess()),
    // );

    // Giả lập thành công
    emit(PaymentCashSuccess());
  }
}