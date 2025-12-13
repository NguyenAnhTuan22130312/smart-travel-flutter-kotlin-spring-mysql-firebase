import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/data/models/tour/tour_detail_model.dart';
import 'package:smart_travel/data/models/tour/tour_image_model.dart';
import 'package:smart_travel/data/models/tour/tour_summary_response_modal.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/domain/params/TourFilterParams.dart';
import 'package:dio/dio.dart';

abstract class TourRemoteDataSource {
  Future<TourDetailModel> getTourDetail(int id);
  Future<List<TourImageModel>> getTourImages(int id);
  Future<List<TourSummaryResponse>> filterTours(TourFilterParams params);
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
    } on DioError catch (e) {
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
    } on DioError catch (e) {
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
  Future<List<TourSummaryResponse>> filterTours(TourFilterParams p) async {
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

      List list = [];
      final data = res.data;

      if (data is Map && data.containsKey("content")) {
        list = data["content"];
      } else if (data is List) {
        list = data;
      }

      return list
          .map((e) => TourSummaryResponse.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException("Lỗi khi gọi filterTours: $e");
    }
  }
}
