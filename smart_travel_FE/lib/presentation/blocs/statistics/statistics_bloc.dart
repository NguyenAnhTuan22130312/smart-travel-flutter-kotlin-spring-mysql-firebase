import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/domain/repositories/statistics_repository.dart';
import 'package:smart_travel/presentation/blocs/statistics/statistics_event.dart';
import 'package:smart_travel/presentation/blocs/statistics/statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final StatisticsRepository repository;

  StatisticsBloc({required this.repository}) : super(StatisticsInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());

    final result = await repository.getDashboardStats();

    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (stats) => emit(StatisticsLoaded(stats)),
    );
  }
}
