import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'payment_event.dart';
import 'payment_state.dart';
// TODO: Import UseCase và DTO khi kết nối API
// import 'package:smart_travel/domain/usecases/payment/process_payment_usecase.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  // TODO: Thêm UseCase
  // final ProcessPaymentUseCase processPaymentUseCase;

  PaymentBloc(
      // {required this.processPaymentUseCase}
      ) : super(PaymentInitial()) {
    on<ProcessPaymentSubmitted>(_onProcessPaymentSubmitted);
  }

  Future<void> _onProcessPaymentSubmitted(
      ProcessPaymentSubmitted event,
      Emitter<PaymentState> emit,
      ) async {
    emit(PaymentLoading());

    // --- GIẢ LẬP GỌI API ---
    // (Đây là nơi bạn sẽ gọi UseCase)
    await Future.delayed(Duration(seconds: 2));

    // Giả lập thành công:
    // API backend của bạn trả về { "paymentUrl": "..." }
    const mockUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?mock=true";
    emit(PaymentSuccess(mockUrl));

    // Giả lập thất bại (bạn có thể test bằng cách đổi sang dòng này)
    // emit(PaymentFailure("Không thể tạo link thanh toán."));

    /* --- Code thật sẽ như thế này ---
    final request = ProcessPaymentRequest( // DTO từ domain
      bookingId: event.bookingId,
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    );
    final result = await processPaymentUseCase(request);

    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (paymentResponse) => emit(PaymentSuccess(paymentResponse.paymentUrl)),
    );
    */
  }
}