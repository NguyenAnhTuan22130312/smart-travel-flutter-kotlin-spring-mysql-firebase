import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/invoice/search_event.dart';
import 'package:smart_travel/presentation/blocs/invoice/search_state.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/usecases/invoice/search_active_invoices_usecase.dart';




class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchActiveInvoicesUseCase searchUseCase;

  SearchBloc(this.searchUseCase) : super(SearchInitial()) {
    on<SearchInvoices>((event, emit) async {
      emit(SearchLoading());
      try {
        final invoices = await searchUseCase(keyword: event.keyword);
        emit(SearchLoaded(invoices));
      } catch (e) {
        emit(SearchError(e.toString()));
      }
    });
  }
}