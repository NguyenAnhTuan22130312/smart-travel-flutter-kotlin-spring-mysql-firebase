import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http ;
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/province/province_add_request.dart';
import 'package:smart_travel/data/models/province/province_detail_response_modal.dart';
import 'package:smart_travel/data/models/province/province_response_modal.dart';

abstract class ProvinceDataSource{
  ///Lấy danh sách tỉnh thành phổ biến
  Future<List<ProvinceModal>> getAllProvince();
  /// Thêm tỉnh thành
  Future<ProvinceModal> addProvince (ProvinceAddRequest req);

  ///Xem tỉnh thành chi tiết
  Future<ProvinceDetailResponseModal> getProvinceDetail(int provinceId);




}
class ProvinceDataSourceImpl implements ProvinceDataSource{
  final http.Client client;

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
    } on http.ClientException catch (e) {
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
    } on http.ClientException catch (e) {
      throw NetworkException('Lỗi kết nối: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  @override
  Future<ProvinceModal> addProvince(ProvinceAddRequest req, {XFile? imageFile}) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'data': req.toJson(), // Gửi JSON dưới dạng String
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          ),
      });

      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.addProvince}',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      ).timeout(ApiConstants.connectionTimeout);

      // Xử lý response giống hệt backend trả về
      final apiResponse = ApiResponseModel<dynamic>.fromJson(
        response.data,
            (data) => data,
      );

      if (response.statusCode == 201 && apiResponse.data != null) {
        return ProvinceModal.formJson(apiResponse.data);
      } else {
        throw ServerException(apiResponse.msg ?? 'Thêm tỉnh thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorResponse = ApiResponseModel.fromJson(
          e.response?.data,
              (_) => null,
        );
        throw ServerException(errorResponse.msg ?? 'Dữ liệu không hợp lệ');
      }
      throw NetworkException('Lỗi kết nối: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: $e');
    }
  }
}