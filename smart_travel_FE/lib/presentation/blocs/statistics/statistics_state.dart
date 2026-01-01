import 'package:equatable/equatable.dart';
import 'package:smart_travel/data/models/statistics/dashboard_stats.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final DashboardStats stats;

  const StatisticsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}
