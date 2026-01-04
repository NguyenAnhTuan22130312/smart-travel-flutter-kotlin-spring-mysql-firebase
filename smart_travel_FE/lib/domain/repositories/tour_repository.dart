import 'dart:io';

import 'package:smart_travel/data/models/tour/tour_image_model.dart';
import 'package:smart_travel/domain/entities/tour_detail.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';
import 'package:smart_travel/domain/entities/tour.dart';
import 'package:smart_travel/data/models/tour/admin_tour_model.dart';

abstract class TourRepository {
  Future<TourDetail> getTourDetail(int id);
  Future<dynamic> filterTours(TourFilterParams params);
  Future<dynamic> getTours({int page = 0, int size = 10});
  Future<AdminTourModel> getToursDetail(int id);
  Future<AdminTourModel> createTour(Map<String, dynamic> body);
  Future<void> updateTour(int id, Map<String, dynamic> body);
  Future<void> deleteTour(int id);
  Future<TourImageModel> uploadTourImage(int tourId, File file);
  Future<void> deleteTourImage(int imageId);
  Future<void> setPrimaryImage(int imageId);
  Future<TourImageModel> addImage(int tourId, File file,
      {bool isPrimary = false, int displayOrder = 0});
  Future<TourImageModel> updateImage(int imageId,
      {File? file, bool? isPrimary, int? displayOrder});
  Future<List<TourImageModel>> addImagesBulk(int tourId, List<File> files);
  Future<List<TourImageModel>> getTourImages(int tourId);
}
