import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smart_travel/data/models/tour/tour_detail_model.dart';
import 'package:smart_travel/data/models/tour/tour_image_model.dart';
import 'package:smart_travel/data/models/tour/tour_summary_response_modal.dart';
import 'package:smart_travel/domain/repositories/tour_repository.dart';
import 'package:smart_travel/domain/entities/tour_detail.dart';
import 'package:smart_travel/data/data_sources/remote/tour_remote_data_source.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';
import 'package:smart_travel/domain/entities/tour.dart';
import 'package:smart_travel/data/models/tour/admin_tour_model.dart';

class TourRepositoryImpl implements TourRepository {
  final TourRemoteDataSource remote;

  TourRepositoryImpl(this.remote);

  @override
  Future<TourDetail> getTourDetail(int id) async {
    try {
      // Lấy chi tiết tour
      final detailModel = await remote.getTourDetail(id);
      if (detailModel == null) {
        throw ServerException("Không tìm thấy chi tiết tour với id = $id");
      }

      // Lấy danh sách ảnh tour
      final images = await remote.getTourImages(id);
      if (images == null) {
        throw ServerException(
            "Không nhận được danh sách ảnh cho tour id = $id");
      }

      // Gộp vào model
      final updatedModel = TourDetailModel(
        id: detailModel.id,
        name: detailModel.name,
        description: detailModel.description,
        durationDays: detailModel.durationDays,
        durationNights: detailModel.durationNights,
        pricePerPerson: detailModel.pricePerPerson,
        averageRating: detailModel.averageRating,
        included: detailModel.included,
        excluded: detailModel.excluded,
        schedules: detailModel.schedules,
        images: images,
      );

      return updatedModel.toEntity();
    } catch (e) {
      // Bắt lỗi API hoặc decode
      throw ServerException("Lỗi khi tải chi tiết tour: ${e.toString()}");
    }
  }

  @override
  Future<dynamic> filterTours(TourFilterParams params) async {
    final list = await remote.filterTours(params);
    return list;
  }

  @override
  Future<dynamic> getTours({int page = 0, int size = 10}) {
    return remote.getTours(page: page, size: size);
  }

  @override
  Future<AdminTourModel> getToursDetail(int id) async {
    try {
      // Lấy chi tiết tour
      final adminDetailModel = await remote.getToursDetail(id);
      if (adminDetailModel == null) {
        throw ServerException("Không tìm thấy chi tiết tour với id = $id");
      }

      // Lấy danh sách ảnh tour
      final images = await remote.getTourImages(id);
      if (images == null) {
        throw ServerException(
            "Không nhận được danh sách ảnh cho tour id = $id");
      }

      // Gộp vào model
      final updatedModel = AdminTourModel(
        id: adminDetailModel.id,
        name: adminDetailModel.name,
        description: adminDetailModel.description,
        durationDays: adminDetailModel.durationDays,
        durationNights: adminDetailModel.durationNights,
        pricePerPerson: adminDetailModel.pricePerPerson,
        averageRating: adminDetailModel.averageRating,

        destinationName: adminDetailModel.destinationName,
        isActive: adminDetailModel.isActive,
        maxPeople: adminDetailModel.maxPeople,
        minPeople: adminDetailModel.minPeople,
        bookingCount: adminDetailModel.bookingCount,
        createdAt: adminDetailModel.createdAt,

        included: adminDetailModel.included,
        excluded: adminDetailModel.excluded,
        schedules: adminDetailModel.schedules,
        images: adminDetailModel.images,
        image: adminDetailModel.image,
        destinationId: adminDetailModel.destinationId,
      );
      return updatedModel;
    } catch (e) {
      // Bắt lỗi API hoặc decode
      throw ServerException("Lỗi khi tải chi tiết tour: ${e.toString()}");
    }
  }

  @override
  Future<AdminTourModel> createTour(Map<String, dynamic> body) {
    return remote.createTour(body);
  }

  @override
  Future<void> updateTour(int id, Map<String, dynamic> body) {
    return remote.updateTour(id, body);
  }

  @override
  Future<void> deleteTour(int id) {
    return remote.deleteTour(id);
  }

  // ==================== IMAGE ====================
  @override
  Future<TourImageModel> uploadTourImage(int tourId, File file) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    return remote.uploadTourImage(tourId, formData);
  }

  @override
  Future<TourImageModel> addImage(int tourId, File file,
      {bool isPrimary = false, int displayOrder = 0}) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      "isPrimary": isPrimary,
      "displayOrder": displayOrder,
    });
    return remote.addImage(tourId, formData);
  }

  @override
  Future<TourImageModel> updateImage(int imageId,
      {File? file, bool? isPrimary, int? displayOrder}) async {
    final formData = FormData.fromMap({
      if (file != null) "file": await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      if (isPrimary != null) "isPrimary": isPrimary,
      if (displayOrder != null) "displayOrder": displayOrder,
    });
    return remote.updateImage(imageId, formData);
  }

  @override
  Future<List<TourImageModel>> addImagesBulk(int tourId, List<File> files) async {
    final formData = FormData.fromMap({
      "files": [
        for (var file in files)
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      ]
    });
    return remote.addImagesBulk(tourId, formData);
  }

  @override
  Future<void> deleteTourImage(int imageId) {
    return remote.deleteTourImage(imageId);
  }

  @override
  Future<void> setPrimaryImage(int imageId) async {
    try {
      await remote.setPrimaryImage(imageId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TourImageModel>> getTourImages(int tourId) => remote.getTourImages(tourId);
}
