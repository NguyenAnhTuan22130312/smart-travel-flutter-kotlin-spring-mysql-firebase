import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/refund_event.dart';
import 'package:smart_travel/presentation/blocs/invoice/refund_state.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/usecases/invoice/get_refunded_invoices_usecase.dart';




class RefundBloc extends Bloc<RefundEvent, RefundState> {
  final GetRefundedInvoicesUseCase getRefundedInvoicesUseCase;

  RefundBloc(this.getRefundedInvoicesUseCase) : super(RefundInitial()) {
    on<LoadRefundedInvoices>((event, emit) async {
      emit(RefundLoading());
      try {
        final invoices = await getRefundedInvoicesUseCase();
        emit(RefundLoaded(invoices));
      } catch (e) {
        emit(RefundError(e.toString()));
      }
    });
  }
}