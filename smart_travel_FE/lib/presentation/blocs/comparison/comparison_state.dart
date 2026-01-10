import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/tour.dart';
import 'package:smart_travel/domain/entities/hotel.dart';

abstract class ComparisonState extends Equatable {
  const ComparisonState();
  @override
  List<Object?> get props => [];
}

class ComparisonInitial extends ComparisonState {}
class ComparisonLoading extends ComparisonState {}

class ComparisonSelectionLoaded extends ComparisonState {
  // Dùng dynamic cho tour nếu entity Tour chưa chuẩn, hoặc dùng Tour nếu đã ok
  final List<dynamic> tours;
  final List<Hotel> hotels;

  const ComparisonSelectionLoaded({
    this.tours = const [],
    this.hotels = const [],
  });

  ComparisonSelectionLoaded copyWith({List<dynamic>? tours, List<Hotel>? hotels}) {
    return ComparisonSelectionLoaded(
      tours: tours ?? this.tours,
      hotels: hotels ?? this.hotels,
    );
  }
  @override
  List<Object?> get props => [tours, hotels];
}

class ComparisonError extends ComparisonState {
  final String message;
  const ComparisonError(this.message);
  @override
  List<Object?> get props => [message];
}