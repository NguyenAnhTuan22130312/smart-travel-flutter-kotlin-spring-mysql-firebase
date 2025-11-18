import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/destination/destination_detail_response_modal.dart';
import 'package:smart_travel/data/models/destination/destination_response_modal.dart';
import 'package:smart_travel/data/models/destination/destinations-featured-response-modal.dart';

abstract class DestinationDataSource {

  ///Lấy danh sách địa điểm nổi bật
  Future<List<DestinationFeaturedResponseModel>> getAllDestinationFeatured();

  ///Lấy danh sách địa điểm
  Future<List<DestinationResponseModal>> getAllDestination();

  /// Lọc danh sách địa điểm
  Future<List<DestinationResponseModal>> filterDestinationsByCategory(String category);

  ///Xem chi tiết địa điểm
  Future<DestinationDetailResponse> getDestinationDetail(int id);


}
class DestinationDataSourceImpl implements DestinationDataSource{
  final http.Client client;

  DestinationDataSourceImpl({required this.client});

  @override
  Future<List<DestinationFeaturedResponseModel>> getAllDestinationFeatured() async {
    try {
      final response = await client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.destinationFeatured}'),
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
        final destinations = apiResponse.data!
            .map((item) => DestinationFeaturedResponseModel.fromJson(item))
            .toList();


        return destinations;
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
  Future<List<DestinationResponseModal>> getAllDestination() async {
    try {
      final response = await client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.destinationAll}'),
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
        final destinations = apiResponse.data!
            .map((item) => DestinationResponseModal.fromJson(item))
            .toList();

        return destinations;
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
  Future<List<DestinationResponseModal>> filterDestinationsByCategory(String category) async {
    try {
      final response = await client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.destinationFilter}?category=$category'),
        headers: {
          'Content-Type': 'application/json',
        },
      )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        // Parse JSON body
        final apiResponse = ApiResponseModel<List<DestinationResponseModal>>.fromJson(
          jsonDecode(response.body),
              (data) => (data as List)
                  .map((e) => DestinationResponseModal.fromJson(e))
                  .toList(),
        );

        // Kiểm tra data null
        if (apiResponse.data == null) {
          throw const ServerException('Không nhận được dữ liệu từ server');
        }
        return apiResponse.data!;
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
  Future<DestinationDetailResponse> getDestinationDetail(int id) async {
    try {
      final response = await client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.destinationDetail}$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        // Parse JSON body
        final apiResponse = ApiResponseModel<DestinationDetailResponse>.fromJson(
          jsonDecode(response.body),
              (data) => DestinationDetailResponse.fromJson(data),
        );
        print(apiResponse);
        // Kiểm tra data null
        if (apiResponse.data == null) {
          throw const ServerException('Không nhận được dữ liệu từ server');
        }
        return apiResponse.data!;

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


}
