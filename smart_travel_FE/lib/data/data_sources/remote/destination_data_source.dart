import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/api_response_model.dart';
import 'package:smart_travel/data/models/destination/destination_add_request.dart';
import 'package:smart_travel/data/models/destination/destination_detail_response_modal.dart';
import 'package:smart_travel/data/models/destination/destination_response_modal.dart';
import 'package:smart_travel/data/models/destination/destination_upate_request.dart';
import 'package:smart_travel/data/models/destination/destinations-featured-response-modal.dart';
import 'package:smart_travel/data/models/destination/weather_data_model.dart';
import 'package:smart_travel/data/models/user/user_level_model.dart';
import 'package:smart_travel/domain/params/destination_update_params.dart';

abstract class DestinationDataSource {

  ///Lấy danh sách địa điểm nổi bật
  Future<List<DestinationFeaturedResponseModel>> getAllDestinationFeatured();

  ///Lấy danh sách địa điểm
  Future<List<DestinationResponseModal>> getAllDestination();

  /// Lọc danh sách địa điểm
  Future<List<DestinationResponseModal>> filterDestinationsByCategory(String category);

  ///Xem chi tiết địa điểm
  Future<DestinationDetailResponse> getDestinationDetail(int id);

  ///thêm địa điểm
  Future<DestinationDetailResponse> addDestination(DestinationAddRequest request, List<XFile>? imageXFile);

  ///Cập nhật địa điểm
  Future<DestinationDetailResponse> updateDestination(int destinationId, DestinationUpdateRequest request, List<XFile>? imageXFile);

  ///Xóa địa điểm
  Future<String> deleteDestination(int destinationId);

  ///Lấy thời tiết
  Future<WeatherDataModel> weather(double latitude, double longitude);

  // Voice
  Future<UserLevelModel> completeVoice(int destinationId);
}
class DestinationDataSourceImpl implements DestinationDataSource{
  final DioClient client;
  final String apiKey = '50e28d94f9cc85814a17ce5c46a53898';


  DestinationDataSourceImpl({required this.client});

  ///Lấy danh sách địa điểm nổi bật
  @override
  Future<List<DestinationFeaturedResponseModel>> getAllDestinationFeatured() async {
    try {
      final response = await client
          .get('${ApiConstants.destinationFeatured}');

      if (response.statusCode == 200) {
        // Parse JSON body
        final apiResponse = ApiResponseModel<List<dynamic>>.fromJson(
          response.data,
              (data) => data as List<dynamic>,
        );

        // Convert từng phần tử JSON trong list thành model
        final destinations = apiResponse.data!
            .map((item) => DestinationFeaturedResponseModel.fromJson(item))
            .toList();

        return destinations;
      } else if (response.statusCode == 400) {
        final apiResponse = ApiResponseModel.fromJson(
          response.data,
          null,
        );
        throw ServerException(apiResponse.msg);
      } else {
        throw ServerException(
            'Lỗi server: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Lỗi không xác định");
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  /// Lấy danh sách địa điểm
  @override
  Future<List<DestinationResponseModal>> getAllDestination() async {
    try {
      final response = await client
          .get('${ApiConstants.destinationAll}');

        // Parse JSON body
        final apiResponse = ApiResponseModel<List<dynamic>>.fromJson(
       response.data,
              (data) => data as List<dynamic>,
        );

        // Convert từng phần tử JSON trong list thành model
        final destinations = apiResponse.data!
            .map((item) => DestinationResponseModal.fromJson(item))
            .toList();

        return destinations;
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Lỗi không xác định");
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  ///Lọc địa điểm theo danh mục
  @override
  Future<List<DestinationResponseModal>> filterDestinationsByCategory(String category) async {
    try {
      final response = await client
          .get(
        '${ApiConstants.destinationFilter}?category=$category'
      );

        // Parse JSON body
        final apiResponse = ApiResponseModel<List<DestinationResponseModal>>.fromJson(
          response.data,
              (data) => (data as List)
                  .map((e) => DestinationResponseModal.fromJson(e))
                  .toList(),
        );

        return apiResponse.data!;

    } on DioException catch (e) {
      throw ServerException(e.message ?? "Lỗi không xác định");
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  ///Xem chi tiết dđịa điểm
  @override
  Future<DestinationDetailResponse> getDestinationDetail(int id) async {
    try {
      final response = await client
          .get('${ApiConstants.destinationDetail}$id');


        // Parse JSON body
        final apiResponse = ApiResponseModel<DestinationDetailResponse>.fromJson(
         response.data,
              (data) => DestinationDetailResponse.fromJson(data),
        );

        return apiResponse.data!;

    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi xem chi tiết địa điểm');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  ///Thêm địa điểm
  @override
  Future<DestinationDetailResponse> addDestination(DestinationAddRequest request, List<XFile>? imageFiles) async {
    try {
      // Chuẩn bị JSON part
      final jsonPart = await MultipartFile.fromString(
        jsonEncode(request.toJson()),
        filename: 'request.json',
        contentType: DioMediaType('application', 'json'), // hoặc MediaType.json
      );

      // Chuẩn bị danh sách ảnh
      List<MultipartFile> imageParts = [];
      if (imageFiles != null && imageFiles.isNotEmpty) {
        imageParts = await Future.wait(
          imageFiles.map((file) => MultipartFile.fromFile(
            file.path,
            filename: file.name,
          )),
        );
      }

      //Tạo FormData
      final formData = FormData.fromMap({
        'request': jsonPart,
        if (imageParts.isNotEmpty) 'imageFiles': imageParts,
      });

      final response = await client.post(
          ApiConstants.addDestination,
          data: formData
      );
      final apiResponse = ApiResponseModel<DestinationDetailResponse>.fromJson(
          response.data,
              (data) => DestinationDetailResponse.fromJson(data)
      );
      return apiResponse.data!;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi thêm địa điểm');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
  }
  }

  ///Cập nhật địa điểm
  @override
  Future<DestinationDetailResponse> updateDestination(int destinationId, DestinationUpdateRequest request, List<XFile>? imageFiles) async {
    try {
      // Chuẩn bị JSON part
      final jsonPart = await MultipartFile.fromString(
        jsonEncode(request.toJson()),
        filename: 'request.json',
        contentType: DioMediaType('application', 'json'), // hoặc MediaType.json
      );

      // Chuẩn bị danh sách ảnh
      List<MultipartFile> imageParts = [];
      if (imageFiles != null && imageFiles.isNotEmpty) {
        imageParts = await Future.wait(
          imageFiles.map((file) => MultipartFile.fromFile(
            file.path,
            filename: file.name,
          )),
        );
      }

      //Tạo FormData
      final formData = FormData.fromMap({
        'request': jsonPart,
        if (imageParts.isNotEmpty) 'imageFiles': imageParts,
      });

      final response = await client.put(
          '${ApiConstants.updateDestination}${destinationId}',
          data: formData
      );
      final apiResponse = ApiResponseModel<DestinationDetailResponse>.fromJson(
          response.data,
              (data) => DestinationDetailResponse.fromJson(data)
      );
      return apiResponse.data!;
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi cập nhật địa điểm');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không mong muốn: ${e.toString()}');
    }
  }

  /// Xóa địa điểm
  @override
  Future<String> deleteDestination(int destinationId) async {
    try {
      final response = await client.delete(
        '${ApiConstants.deleteDestination}$destinationId',
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

  @override
  Future<WeatherDataModel> weather(double latitude, double longitude) async{
    try {
      final response = await client.get(
        '${ApiConstants.weather}weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
      );
      print("WEATHER: ${response.data}");

      final resu = WeatherDataModel.fromJson(response.data);
      print("WEATHER: ${resu}");
      return WeatherDataModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi khi lấy thông tin thời tiết');
    }
  }

  @override
  Future<UserLevelModel> completeVoice(int destinationId) async {
    try {
      // Gọi đến API: /api/destinations/{id}/voice-complete
      final response = await client.post(
        '${ApiConstants.completeVoice}$destinationId/voice-complete',
      );

      // Dùng lại ApiResponseModel của bạn để parse
      final apiResponse = ApiResponseModel<UserLevelModel>.fromJson(
        response.data,
            (data) => UserLevelModel.fromJson(data),
      );

      return apiResponse.data!;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi khi hoàn thành nghe thuyết minh');
    } catch (e) {
      throw ServerException('Lỗi không xác định: ${e.toString()}');
    }
  }

}
