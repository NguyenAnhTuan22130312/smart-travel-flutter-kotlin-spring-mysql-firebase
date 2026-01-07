import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/admin_invoice.dart';
import '../../../domain/usecases/invoice/get_admin_invoices_usecase.dart';

abstract class AdminInvoiceEvent {}

class LoadAdminInvoices extends AdminInvoiceEvent {
  final String? status;
  final String? invoiceNumber;

  LoadAdminInvoices({this.status, this.invoiceNumber});
}

abstract class AdminInvoiceState {}

class AdminInvoiceLoading extends AdminInvoiceState {}

class AdminInvoiceLoaded extends AdminInvoiceState {
  final List<AdminInvoice> invoices;

  AdminInvoiceLoaded(this.invoices);
}

class AdminInvoiceError extends AdminInvoiceState {
  final String message;

  AdminInvoiceError(this.message);
}

class AdminInvoiceBloc extends Bloc<AdminInvoiceEvent, AdminInvoiceState> {
  final GetAdminInvoicesUseCase getAdminInvoicesUseCase;

  AdminInvoiceBloc(this.getAdminInvoicesUseCase) : super(AdminInvoiceLoading()) {
    on<LoadAdminInvoices>((event, emit) async {
      emit(AdminInvoiceLoading());
      try {
        final invoices = await getAdminInvoicesUseCase(
          status: event.status,
          invoiceNumber: event.invoiceNumber,
        );
        emit(AdminInvoiceLoaded(invoices));
      } catch (e) {
        emit(AdminInvoiceError(e.toString()));
      }
    });
  }
}