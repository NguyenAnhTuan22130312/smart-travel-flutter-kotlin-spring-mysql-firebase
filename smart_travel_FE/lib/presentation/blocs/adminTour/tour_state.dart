import 'package:equatable/equatable.dart';
import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
import 'package:smart_travel/data/models/tour/tour_detail_model.dart';
import 'package:smart_travel/data/models/tour/tour_image_model.dart';

abstract class AdminTourState extends Equatable {
  const AdminTourState();

  @override
  List<Object?> get props => [];
}

class AdminTourInitial extends AdminTourState {}

class AdminTourLoading extends AdminTourState {}

class AdminTourCreateSuccess extends AdminTourState {
  final AdminTourModel tour;
  AdminTourCreateSuccess(this.tour);

  @override
  List<Object?> get props => [tour];
}


/// List tours loaded
class AdminTourLoaded extends AdminTourState {
  final List<AdminTourModel> tours;
  final int currentPage; // Thêm
  final int totalPages;  // Thêm

  const AdminTourLoaded(this.tours, {this.currentPage = 0, this.totalPages = 1});

  @override
  List<Object?> get props => [tours, currentPage, totalPages];
}

class AdminTourError extends AdminTourState {
  final String message;

  const AdminTourError(this.message);

  @override
  List<Object?> get props => [message];
}

//Delete Tour
class AdminTourDeleteLoading extends AdminTourState {}

class AdminTourDeleteSuccess extends AdminTourState {}

class AdminTourDeleteError extends AdminTourState {
  final String message;
  AdminTourDeleteError(this.message);
}

class TourImageLoading extends AdminTourState {}

class UploadTourImageSuccess extends AdminTourState {
  final TourImageModel image;

  const UploadTourImageSuccess(this.image);

  @override
  List<Object?> get props => [image];
}

class TourImageActionSuccess extends AdminTourState {}

class TourImageError extends AdminTourState {
  final String message;

  const TourImageError(this.message);

  @override
  List<Object?> get props => [message];
}

class TourImageDeleteSuccess extends AdminTourState {}

