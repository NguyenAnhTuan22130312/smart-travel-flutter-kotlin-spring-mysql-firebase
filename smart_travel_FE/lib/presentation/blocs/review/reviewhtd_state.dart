import 'package:equatable/equatable.dart';
import '../../../domain/entities/reviewhtd.dart';

abstract class ReviewHtdState extends Equatable {
  const ReviewHtdState();

  @override
  List<Object?> get props => [];
}

class ReviewHtdInitial extends ReviewHtdState {}

class ReviewHtdLoading extends ReviewHtdState {}

class ReviewHtdLoaded extends ReviewHtdState {
  final List<ReviewHtd> reviews;

  const ReviewHtdLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class ReviewHtdError extends ReviewHtdState {
  final String message;

  const ReviewHtdError(this.message);

  @override
  List<Object?> get props => [message];
}