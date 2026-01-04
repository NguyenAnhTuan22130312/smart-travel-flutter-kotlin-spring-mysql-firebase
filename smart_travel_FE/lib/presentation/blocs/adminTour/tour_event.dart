import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class AdminTourEvent extends Equatable {
  const AdminTourEvent();

  @override
  List<Object?> get props => [];
}

/// Load list tour
class LoadAdminTours extends AdminTourEvent {
  final int page;
  const LoadAdminTours({this.page = 0});

  @override
  List<Object?> get props => [page];
}

/// Create tour
class CreateAdminTour extends AdminTourEvent {
  final Map<String, dynamic> body;
  const CreateAdminTour(this.body);

  @override
  List<Object?> get props => [body];
}

/// Delete tour
class DeleteAdminTour extends AdminTourEvent {
  final int id;
  const DeleteAdminTour(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleTourStatus extends AdminTourEvent {
  final int tourId;
  final bool isActive;

  ToggleTourStatus({required this.tourId, required this.isActive});

  @override
  List<Object?> get props => [tourId, isActive];
}

/// Images related events
class LoadTourImages extends AdminTourEvent {
  final int tourId;
  const LoadTourImages(this.tourId);

  @override
  List<Object?> get props => [tourId];
}

/// Upload image
class UploadTourImage extends AdminTourEvent {
  final int tourId;
  final File file;

  const UploadTourImage({
    required this.tourId,
    required this.file,
  });

  @override
  List<Object?> get props => [tourId, file];
}

/// Delete image
class DeleteTourImage extends AdminTourEvent {
  final int imageId;

  const DeleteTourImage(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

/// Set primary image
class SetPrimaryTourImage extends AdminTourEvent {
  final int imageId;

  const SetPrimaryTourImage(this.imageId);

  @override
  List<Object?> get props => [imageId];
}