import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/invoice/get_active_invoices_usecase.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final GetActiveInvoicesUseCase getActiveInvoicesUseCase;

  InvoiceBloc(this.getActiveInvoicesUseCase) : super(InvoiceInitial()) {
    on<LoadActiveInvoices>((event, emit) async {
      emit(InvoiceLoading());

      try {
        final invoices = await getActiveInvoicesUseCase.call();
        emit(InvoiceLoaded(invoices));
      } catch (e) {
        emit(InvoiceError(e.toString()));
      }
    });
  }
}