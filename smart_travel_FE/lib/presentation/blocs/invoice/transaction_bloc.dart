import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/transaction_event.dart';
import 'package:smart_travel/presentation/blocs/invoice/transaction_state.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/usecases/invoice/get_transaction_history_usecase.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionHistoryUseCase getHistoryUseCase;

  TransactionBloc(this.getHistoryUseCase) : super(TransactionInitial()) {
    on<LoadTransactionHistory>((event, emit) async {
      emit(TransactionLoading());
      try {
        final invoices = await getHistoryUseCase(type: event.type, status: event.status);
        emit(TransactionLoaded(invoices));
      } catch (e) {
        emit(TransactionError(e.toString()));
      }
    });
  }
}