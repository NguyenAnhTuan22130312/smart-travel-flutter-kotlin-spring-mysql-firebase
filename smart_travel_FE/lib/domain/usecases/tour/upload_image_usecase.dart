import 'dart:io';

import 'package:smart_travel/data/models/tour/tour_image_model.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';

class UploadTourImageUseCase {
  final TourRepository repository;

  UploadTourImageUseCase(this.repository);

  Future<TourImageModel> call(int tourId, File file) {
    return repository.uploadTourImage(tourId, file);
  }
}
