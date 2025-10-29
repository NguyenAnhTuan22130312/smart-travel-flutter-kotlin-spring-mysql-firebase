import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/province/province_detail_response_modal.dart';
import 'package:smart_travel/data/models/province/province_response_modal.dart';

abstract class ProvinceDataSource{
  ///Lấy danh sách tỉnh thành phổ biến
  Future<List<ProvinceModal>> getAllProvince();

  ///Xem tỉnh thành chi tiết
  Future<ProvinceDetailResponseModal> getProvinceDetail(int provinceId);




}
class ProvinceDataSourceImpl implements ProvinceDataSource{
  final Client client;

  ProvinceDataSourceImpl({required this.client});

  @override
  Future<List<ProvinceModal>> getAllProvince() async {
    // TODO: implement getAllProvinceIsPopular
    try {
      final response = await client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.provinceAll}'),
        headers: {
          'Content-Type': 'application/json',
        },
      )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        // Parse JSON body
        final apiResponse = ApiResponseModel<List<dynamic>>.fromJson(
          jsonDecode(response.body),
              (data) => data as List<dynamic>,
        );

        // Kiểm tra data null
        if (apiResponse.data == null) {
          throw const ServerException('Không nhận được dữ liệu từ server');
        }

        // Convert từng phần tử JSON trong list thành model
        final provinceModal = apiResponse.data!
            .map((item) => ProvinceModal.formJson(item))
            .toList();

        return provinceModal;
      } else if (response.statusCode == 400) {
        final apiResponse = ApiResponseModel.fromJson(
          jsonDecode(response.body),
          null,
        );
        throw ServerException(apiResponse.msg);
      } else {
        throw ServerException(
            'Lỗi server: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on ClientException catch (e) {
      throw NetworkException('Lỗi kết nối: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }

  }

  @override
  Future<ProvinceDetailResponseModal> getProvinceDetail(int provinceId) async{
    // TODO: implement getAllProvinceIsPopular
    try {
      final response = await client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.provinceDetail}$provinceId'),
        headers: {
          'Content-Type': 'application/json',
        },
      )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        // Parse JSON body
        final apiResponse = ApiResponseModel<dynamic>.fromJson(
          jsonDecode(response.body),
              (data) => data as dynamic,
        );

        // Kiểm tra data null
        if (apiResponse.data == null) {
          throw const ServerException('Không nhận được dữ liệu từ server');
        }

        // Convert từng phần tử JSON  thành model
        final provinceModal = ProvinceDetailResponseModal.formJson(apiResponse.data);

        return provinceModal;
      } else if (response.statusCode == 400) {
        final apiResponse = ApiResponseModel.fromJson(
          jsonDecode(response.body),
          null,
        );
        throw ServerException(apiResponse.msg);
      } else {
        throw ServerException(
            'Lỗi server: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on ClientException catch (e) {
      throw NetworkException('Lỗi kết nối: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

}