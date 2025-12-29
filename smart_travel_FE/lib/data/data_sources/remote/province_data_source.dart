import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/data_sources/local/auth_local_data_source.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/province/province_add_request.dart';
import 'package:smart_travel/data/models/province/province_detail_response_modal.dart';
import 'package:smart_travel/data/models/province/province_response_modal.dart';
import 'package:smart_travel/data/models/province/province_update_request.dart';

abstract class ProvinceDataSource {
  ///Lấy danh sách tỉnh thành phổ biến
  Future<List<ProvinceModal>> getAllProvince();

  /// Thêm tỉnh thành
  Future<ProvinceModal> addProvince(ProvinceAddRequest req, XFile? imageXFile);

  /// Cập nhật tỉnh thành
  Future<ProvinceModal> updateProvince(int provinceId, ProvinceUpdateRequest req, XFile? imageXFile);

  ///Xem tỉnh thành chi tiết
  Future<ProvinceDetailResponseModal> getProvinceDetail(int provinceId);

  ///Xóa tỉnh thành
  Future<String> deleteProvince(int provinceId);

}

class ProvinceDataSourceImpl implements ProvinceDataSource {
  final DioClient dioClient;
  final AuthLocalDataSource localDataSource;

  ProvinceDataSourceImpl(this.localDataSource, {required this.dioClient});

  @override
  Future<List<ProvinceModal>> getAllProvince() async {
    try {
      final response = await dioClient.get(ApiConstants.provinceAll);

      // Parse JSON body
      final apiResponse = ApiResponseModel<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );

      // Convert từng phần tử JSON trong list thành model
      final provinceModal =
          apiResponse.data!
              .map((item) => ProvinceModal.formJson(item))
              .toList();

      return provinceModal;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi lấy danh sách tỉnh thành');
    }
  }

  @override
  Future<ProvinceDetailResponseModal> getProvinceDetail(int provinceId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.provinceDetail}$provinceId',
      );
      // Parse JSON body
      final apiResponse = ApiResponseModel<dynamic>.fromJson(
        response.data,
        (data) => data as dynamic,
      );
      // Convert từng phần tử JSON  thành model
      final provinceModal = ProvinceDetailResponseModal.formJson(
        apiResponse.data,
      );

      return provinceModal;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi xem chi tiết tỉnh thành');
    }
  }

  @override
  Future<ProvinceModal> addProvince(
    ProvinceAddRequest req,
    XFile? imageFile,
  ) async {
    try {
      final formData = FormData.fromMap({
        "data": MultipartFile.fromString(
          jsonEncode(req.toJson()),
          contentType: http.MediaType("application", "json"),
          filename: "data.json",
        ),
        if (imageFile != null)
          "image": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          ),
      });

      final response = await dioClient.post(
        ApiConstants.addProvince,
        data: formData,
      );

      final apiResponse = ApiResponseModel<dynamic>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      return ProvinceModal.formJson(apiResponse.data);
    } on DioException catch (e) {
      // Xử lý lỗi từ ErrorInterceptor
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi thêm tỉnh thành');
    }
  }

  ///Cập nhật
  @override
  Future<ProvinceModal> updateProvince(
      int provinceId,
      ProvinceUpdateRequest req,
      XFile? imageFile,
      ) async {
    try {
      final formData = FormData.fromMap({
        "data": MultipartFile.fromString(
          jsonEncode(req.toJson()),
          contentType: http.MediaType("application", "json"),
          filename: "data.json",
        ),
        if (imageFile != null)
          "image": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          ),
      });

      final response = await dioClient.put(
        '${ApiConstants.updateProvince}${provinceId}',
         data: formData,
      );

      final apiResponse = ApiResponseModel<dynamic>.fromJson(
        response.data,
            (json) => json as Map<String, dynamic>,
      );

      return ProvinceModal.formJson(apiResponse.data);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi cập nhật tỉnh thành');
    }
  }



  @override
  Future<String> deleteProvince(int provinceId) async {
    try {
      final response = await dioClient.delete(
        '${ApiConstants.deleteProvince}$provinceId',
      );
      final apiResponse = ApiResponseModel<dynamic>.fromJson(
        response.data,
        (data) => data,
      );
      return apiResponse.msg;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi xóa tỉnh thành');
    }
  }
}
