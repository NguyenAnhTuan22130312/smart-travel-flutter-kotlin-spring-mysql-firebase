import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/data/models/tour/tour_detail_model.dart';
import 'package:smart_travel/data/models/tour/tour_image_model.dart';
import 'package:smart_travel/data/models/tour/tour_summary_response_modal.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';
import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
import 'package:dio/dio.dart';

abstract class TourRemoteDataSource {
  Future<TourDetailModel> getTourDetail(int id);
  Future<List<TourImageModel>> getTourImages(int id);
  Future<dynamic> filterTours(TourFilterParams params);
  Future<dynamic> getTours({int page = 0, int size = 10});
  Future<AdminTourModel> getToursDetail(int id);
  Future<AdminTourModel> createTour(Map<String, dynamic> body);
  Future<void> updateTour(int id, Map<String, dynamic> body);
  Future<void> deleteTour(int id);
  Future<TourImageModel> uploadTourImage(int tourId, FormData data);
  Future<void> deleteTourImage(int imageId);
  Future<void> setPrimaryImage(int imageId);
  Future<TourImageModel> addImage(int tourId, FormData data);
  Future<TourImageModel> updateImage(int imageId, FormData data);
  Future<List<TourImageModel>> addImagesBulk(int tourId, FormData data);
}

class TourRemoteDataSourceImpl implements TourRemoteDataSource {
  final DioClient client;

  TourRemoteDataSourceImpl({required this.client});

  @override
  Future<TourDetailModel> getTourDetail(int id) async {
    try {
      final res = await client.get(
        "${ApiConstants.baseUrl}${ApiConstants.tourDetail}$id",
      );

      if (res.data == null || res.data.isEmpty) {
        throw const ServerException("Không nhận được dữ liệu tour");
      }

      return TourDetailModel.fromJson(res.data);
    } on DioException catch (e) {
      // Kiểm tra lỗi kết nối Internet
      if (e.type == DioErrorType.unknown) {
        throw const ServerException("Không có kết nối Internet");
      } else {
        throw ServerException("Lỗi API getTourDetail: ${e.message}");
      }
    } catch (e) {
      throw ServerException("Lỗi không xác định: ${e.toString()}");
    }
  }

  @override
  Future<List<TourImageModel>> getTourImages(int id) async {
    try {
      final res = await client.get(
        "${ApiConstants.baseUrl}${ApiConstants.tourDetail}$id/images",
      );

      if (res.data == null) {
        throw const ServerException("Không nhận được danh sách ảnh tour");
      }

      final list = res.data as List;
      return list.map((e) => TourImageModel.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.type == DioErrorType.unknown) {
        throw const ServerException("Không có kết nối Internet");
      } else {
        throw ServerException("Lỗi API getTourImages: ${e.message}");
      }
    } catch (e) {
      throw ServerException("Lỗi không xác định: ${e.toString()}");
    }
  }

  @override
  Future<dynamic> filterTours(TourFilterParams p) async {
    final base = "${ApiConstants.tour}/filter";

    final query = <String, dynamic>{
      if (p.keyword != null && p.keyword!.isNotEmpty) "keyword": p.keyword,
      if (p.minPrice != null) "minPrice": p.minPrice.toString(),
      if (p.maxPrice != null) "maxPrice": p.maxPrice.toString(),
      if (p.minDays != null) "minDays": p.minDays.toString(),
      if (p.maxDays != null) "maxDays": p.maxDays.toString(),
      if (p.minPeople != null) "minPeople": p.minPeople.toString(),
      if (p.minRating != null) "minRating": p.minRating.toString(),
      if (p.sort != null) "sort": p.sort,
      "page": p.page.toString(),
      "size": p.size.toString(),
    };

    final uri = Uri(
      path: base,
      queryParameters: query,
    ).toString();

    try {
      final res = await client.get(uri);

      final data = res.data;

      return data;
    } catch (e) {
      throw ServerException("Lỗi khi gọi filterTours: $e");
    }
  }

  @override
  Future<dynamic> getTours({int page = 0, int size = 10}) async {
    try {
      final String urlWithParams = "${ApiConstants.baseUrl}${ApiConstants.adminTours}?page=$page&size=$size";

      final res = await client.get(urlWithParams);
      return res.data;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AdminTourModel> getToursDetail(int id) async {
    try {
      final res = await client.get(
        "${ApiConstants.baseUrl}${ApiConstants.adminTourDetail}$id",
      );

      if (res.data == null) {
        throw const ServerException("Không có dữ liệu tour");
      }

      return AdminTourModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ServerException("Lỗi getTourDetail: ${e.message}");
    }
  }

  @override
  Future<AdminTourModel> createTour(Map<String, dynamic> body) async {
    try {
      final res = await client.post(
        "${ApiConstants.baseUrl}${ApiConstants.adminTours}",
        data: body,
      );

      if (res.data == null) {
        throw const ServerException("Create tour trả về null");
      }

      return AdminTourModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ServerException("Lỗi createTour: ${e.response?.data ?? e.message}");
    }
  }


  @override
  Future<void> updateTour(int id, Map<String, dynamic> body) async {
    try {
      final res = await client.put(
        "${ApiConstants.baseUrl}${ApiConstants.adminTourDetail}$id",
        data: body,
      );

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw ServerException(
          "HTTP ${res.statusCode}: ${res.data}",
        );
      }

    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?.toString() ??
            e.message ??
            'Update tour error',
      );
    }
  }

  @override
  Future<void> deleteTour(int id) async {
    try {
      await client.delete(
        "${ApiConstants.baseUrl}${ApiConstants.adminTourDetail}$id",
      );
    } on DioException catch (e) {
      throw ServerException("Lỗi deleteTour: ${e.message}");
    }
  }

  @override Future<TourImageModel> uploadTourImage(int tourId, FormData data) async {
    try {
      final res = await client.post( "${ApiConstants.baseUrl}${ApiConstants.adminTourDetail}$tourId/images", data: data, );

    return TourImageModel.fromJson(res.data);
  } on DioException
  catch (e) {
    throw ServerException("Upload image failed: ${e.message}");
    }
  }

  @override
  Future<void> deleteTourImage(int imageId) async {
    try {
      await client.delete(
        "${ApiConstants.baseUrl}${ApiConstants.adminTours}/images/$imageId",
      );
    } on DioException catch (e) {
      throw ServerException("Delete image failed: ${e.message}");
    }
  }

  @override
  Future<void> setPrimaryImage(int imageId) async {
    try {
      await client.put(
        "${ApiConstants.baseUrl}${ApiConstants.adminTours}/images/$imageId/primary",
      );
    } on DioException catch (e) {
      throw ServerException("Set primary failed: ${e.message}");
    }
  }

  @override
  Future<TourImageModel> addImage(int tourId, FormData data) async {
    final res = await client.post("${ApiConstants.baseUrl}${ApiConstants.adminTourDetail}$tourId/images", data: data);
    return TourImageModel.fromJson(res.data);
  }

  @override
  Future<TourImageModel> updateImage(int imageId, FormData data) async {
    final res = await client.put("${ApiConstants.baseUrl}${ApiConstants.adminTours}/images/$imageId", data: data);
    return TourImageModel.fromJson(res.data);
  }

  @override
  Future<List<TourImageModel>> addImagesBulk(int tourId, FormData data) async {
    final res = await client.post("${ApiConstants.baseUrl}${ApiConstants.adminTourDetail}$tourId/images/bulk", data: data);
    final list = res.data as List;
    return list.map((e) => TourImageModel.fromJson(e)).toList();
  }

}
