import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/invoice_detail.dart';
import '../../../domain/usecases/invoice/get_invoice_detail_usecase.dart';

abstract class DetailEvent {}

class LoadInvoiceDetail extends DetailEvent {
  final int bookingId;
  LoadInvoiceDetail(this.bookingId);
}

abstract class DetailState {}

class DetailInitial extends DetailState {}

class DetailLoading extends DetailState {}

class DetailLoaded extends DetailState {
  final InvoiceDetail detail;
  DetailLoaded(this.detail);
}

class DetailError extends DetailState {
  final String message;
  DetailError(this.message);
}

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final GetInvoiceDetailUseCase getDetailUseCase;

  DetailBloc(this.getDetailUseCase) : super(DetailInitial()) {
    on<LoadInvoiceDetail>((event, emit) async {
      emit(DetailLoading());
      try {
        final detail = await getDetailUseCase(bookingId: event.bookingId);
        emit(DetailLoaded(detail));
      } catch (e) {
        emit(DetailError(e.toString()));
      }
    });
  }
}