import 'package:equatable/equatable.dart';
import 'package:smart_travel/domain/entities/tour.dart';

class TourState extends Equatable {
  final bool loading;
  final List<Tour> tours;
  final String? error;

  // --- THÊM 2 BIẾN NÀY ĐỂ PHÂN TRANG ---
  final int currentPage;
  final int totalPages;

  const TourState({
    this.loading = false,
    this.tours = const [],
    this.error,
    this.currentPage = 0,    // Mặc định trang đầu tiên
    this.totalPages = 1,     // Mặc định có ít nhất 1 trang
  });

  TourState copyWith({
    bool? loading,
    List<Tour>? tours,
    String? error,
    int? currentPage,
    int? totalPages,
  }) {
    return TourState(
      loading: loading ?? this.loading,
      tours: tours ?? this.tours,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [loading, tours, error, currentPage, totalPages];
}