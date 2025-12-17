import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/hotel/hotel_create_request.dart';
import 'package:smart_travel/data/models/hotel/hotel_page_modal.dart';
import 'package:smart_travel/data/models/hotel/hotel_detail_response_modal.dart';

abstract class HotelDataSource {
  Future<HotelsPageModel> getHotels({
    int? destinationId,
    String? keyword,
    int? minStars,
    int? maxStars,
    double? minPrice,
    double? maxPrice,
    String? city,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDir,
  });

  Future<HotelDetailResponseModel> getHotelDetail({
    required int hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
  });

  Future<HotelDetailResponseModel> createHotel(HotelCreateRequest request);

  Future<HotelDetailResponseModel> updateHotel(
    int id,
    HotelCreateRequest request,
  );

  Future<String> deleteHotel(int id);

  Future<String> uploadImages(int hotelId, List<File> images);
}

class HotelDataSourceImpl implements HotelDataSource {
  final DioClient client;
  HotelDataSourceImpl({
    required this.client,
  });

  @override
  Future<HotelsPageModel> getHotels({
    int? destinationId,
    String? keyword,
    int? minStars,
    int? maxStars,
    double? minPrice,
    double? maxPrice,
    String? city,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDir,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (destinationId != null)
        queryParameters['destinationId'] = destinationId.toString();
      if (keyword != null) queryParameters['keyword'] = keyword;
      if (minStars != null) queryParameters['minStars'] = minStars.toString();
      if (maxStars != null) queryParameters['maxStars'] = maxStars.toString();
      if (minPrice != null) queryParameters['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParameters['maxPrice'] = maxPrice.toString();
      if (city != null) queryParameters['city'] = city;
      queryParameters['page'] = page.toString();
      queryParameters['size'] = size.toString();
      if (sortBy != null) queryParameters['sortBy'] = sortBy;
      if (sortDir != null) queryParameters['sortDir'] = sortDir;

      final uri = Uri(path: ApiConstants.hotel, queryParameters: queryParameters);

      // Gọi qua DioClient (truyền uri.toString() sẽ ra dạng: /api/v1/hotels?page=0...)
      final response = await client.get(uri.toString());
      developer.log('API getHotels: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Dio tự động decode JSON thành Map hoặc List vào biến response.data
        final bodyData = response.data;

        if (bodyData is Map<String, dynamic>) {
          return HotelsPageModel.fromJson(bodyData);
        } else {
          throw ServerException('Dữ liệu phân trang không đúng định dạng');
        }
      } else {
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Bắt lỗi từ Dio (do ErrorInterceptor ném ra hoặc lỗi mạng)
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      throw ServerException(e.message ?? 'Lỗi kết nối Dio');
    } catch (e, s) {
      developer.log('Lỗi getHotels', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<HotelDetailResponseModel> getHotelDetail({
    required int hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      // Xây dựng path tương đối
      final path = '${ApiConstants.hotel}/$hotelId/detail';
      final queryParams = {
        'checkIn': checkIn.toIso8601String().split('T').first,
        'checkOut': checkOut.toIso8601String().split('T').first,
      };

      final uri = Uri(path: path, queryParameters: queryParams);

      developer.log('Gọi API chi tiết: $uri');

      final response = await client.get(uri.toString());

      if (response.statusCode != 200) {
        throw ServerException('Lỗi server: ${response.statusCode}');
      }

      // Dio đã decode sẵn
      final Map<String, dynamic> jsonMap = response.data;

      // Logic xử lý data wrapper giữ nguyên
      final dataMap = jsonMap['data'] ?? jsonMap;

      if (dataMap is! Map<String, dynamic>) {
        throw ServerException('Dữ liệu không đúng định dạng: $dataMap');
      }

      final model = HotelDetailResponseModel.fromJson(dataMap);
      return model;
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error as ServerException;
      throw ServerException(e.message ?? 'Lỗi kết nối');
    } catch (e, s) {
      developer.log('Lỗi parse chi tiết khách sạn', error: e, stackTrace: s);
      throw ServerException('Lỗi parse chi tiết khách sạn: $e');
    }
  }

  // 3. CREATE HOTEL
  @override
  Future<HotelDetailResponseModel> createHotel(HotelCreateRequest request) async {
    try {
      // DioClient tự thêm token và Content-Type: application/json
      developer.log('Create Hotel Request: ${jsonEncode(request.toJson())}');

      // Truyền thẳng Map vào data, Dio tự jsonEncode
      final response = await client.post(
          ApiConstants.hotel,
          data: request.toJson()
      );

      developer.log('Create Hotel Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return HotelDetailResponseModel.fromJson(response.data);
      } else {
        throw ServerException('Tạo thất bại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error as ServerException;
      rethrow;
    } catch (e, s) {
      developer.log('Lỗi createHotel', error: e, stackTrace: s);
      rethrow;
    }
  }

  // 4. UPDATE HOTEL
  @override
  Future<HotelDetailResponseModel> updateHotel(
      int id,
      HotelCreateRequest request,
      ) async {
    try {
      final path = '${ApiConstants.hotel}/$id';

      developer.log('Update Body: ${jsonEncode(request.toJson())}');

      final response = await client.put(path, data: request.toJson());

      developer.log('Update Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return HotelDetailResponseModel.fromJson(response.data);
      } else {
        throw ServerException('Cập nhật thất bại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error as ServerException;
      rethrow;
    } catch (e, s) {
      developer.log('Lỗi updateHotel', error: e, stackTrace: s);
      rethrow;
    }
  }

  // 5. DELETE HOTEL
  @override
  Future<String> deleteHotel(int id) async {
    try {
      final path = '${ApiConstants.hotel}/$id';

      final response = await client.delete(path);

      developer.log('Delete Hotel Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // response.data có thể là String hoặc Map rỗng
        return "Xóa thành công";
      } else {
        throw ServerException('Xóa thất bại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error as ServerException;
      rethrow;
    } catch (e, s) {
      developer.log('Lỗi deleteHotel', error: e, stackTrace: s);
      rethrow;
    }
  }

  // 6. UPLOAD IMAGES (Dùng FormData của Dio)
  @override
  Future<String> uploadImages(int hotelId, List<File> images) async {
    try {
      final path = '${ApiConstants.hotel}/$hotelId/images/upload';

      developer.log('START UPLOAD Dio: $path');

      // Tạo FormData
      final formData = FormData();

      // Thêm file vào FormData
      for (var image in images) {
        formData.files.add(MapEntry(
          'file', // Key phải khớp với Backend
          await MultipartFile.fromFile(image.path),
        ));
      }

      // Dio tự động set Content-Type: multipart/form-data khi data là FormData
      // AuthInterceptor vẫn sẽ chạy để thêm Token
      final response = await client.post(path, data: formData);

      developer.log('Upload status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        developer.log('Upload thành công!');
        return "Upload thành công";
      } else {
        throw ServerException('Upload thất bại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('Lỗi Upload Dio: ${e.response?.data}');
      if (e.error is ServerException) throw e.error as ServerException;
      // Nếu lỗi 401 thì ErrorInterceptor thường đã catch, nhưng check lại cho chắc
      if (e.response?.statusCode == 401) {
        throw const ServerException('Lỗi xác thực (401) khi upload ảnh.');
      }
      throw ServerException('Lỗi upload: ${e.message}');
    } catch (e, s) {
      developer.log('Exception uploadImages', error: e, stackTrace: s);
      rethrow;
    }
  }

}