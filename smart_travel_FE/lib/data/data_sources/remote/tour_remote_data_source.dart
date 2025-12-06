import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/data/models/tour/tour_detail_model.dart';
import 'package:smart_travel/data/models/tour/tour_image_model.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:dio/dio.dart';

abstract class TourRemoteDataSource {
  Future<TourDetailModel> getTourDetail(int id);
  Future<List<TourImageModel>> getTourImages(int id);
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
}
