import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart';
import 'package:smart_travel/core/constants/api_constants.dart';
import 'package:smart_travel/core/error/exceptions.dart';
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
}

class HotelDataSourceImpl implements HotelDataSource {
  final Client client;

  HotelDataSourceImpl({required this.client});

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

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.hotel}',
      ).replace(queryParameters: queryParameters);

      final response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConstants.connectionTimeout);

      developer.log('API getHotels: ${response.statusCode}\n${response.body}');

      // Thay đổi đoạn này trong HotelDataSourceImpl
      if (response.statusCode == 200) {
        final bodyJson = jsonDecode(response.body);

        // Nếu API trả về object phân trang (HotelsPageModel)
        if (bodyJson is Map<String, dynamic>) {
          return HotelsPageModel.fromJson(
            bodyJson,
          ); // Trả về 1 đối tượng HotelsPageModel
        } else {
          // Xử lý trường hợp bodyJson không phải là Map<String, dynamic>
          throw ServerException('Dữ liệu phân trang không đúng định dạng');
        }
      } else {
        throw ServerException('Lỗi server: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('Không có kết nối internet');
    } on FormatException catch (e) {
      developer.log('JSON Format Error (getHotels)', error: e);
      throw ServerException('Dữ liệu JSON không hợp lệ');
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
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.hotel}/$hotelId/detail',
      ).replace(
        queryParameters: {
          'checkIn': checkIn.toIso8601String().split('T').first,
          'checkOut': checkOut.toIso8601String().split('T').first,
        },
      );

      developer.log('Gọi API chi tiết: $uri');

      final response = await client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConstants.connectionTimeout);

      developer.log(
        'API Detail Response: ${response.statusCode}\n${response.body}',
      );

      if (response.statusCode != 200) {
        throw ServerException('Lỗi server: ${response.statusCode}');
      }

      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      // XỬ LÝ CHUNG CHO CẢ 2 TRƯỜNG HỢP BE TRẢ:
      // 1. { "data": { ... } } → lấy jsonMap['data']
      // 2. Trả thẳng object → dùng luôn jsonMap
      final dataMap = jsonMap['data'] ?? jsonMap;

      if (dataMap is! Map<String, dynamic>) {
        throw ServerException('Dữ liệu không đúng định dạng: $dataMap');
      }

      final model = HotelDetailResponseModel.fromJson(dataMap);
      developer.log(
        'Parse thành công HotelDetailResponseModel: ${model.name} (ID: ${model.id})',
      );

      return model;
    } on SocketException {
      throw NetworkException('Không có kết nối internet');
    } on FormatException catch (e, s) {
      developer.log(
        'JSON Format Error (getHotelDetail)',
        error: e,
        stackTrace: s,
      );
      throw ServerException('Dữ liệu JSON không hợp lệ');
    } on TypeError catch (e, s) {
      developer.log(
        'TypeError khi parse → LỖI NÀY SẼ HIỆN RÕ TRONG LOG',
        error: e,
        stackTrace: s,
      );
      throw ServerException('Lỗi kiểu dữ liệu: $e');
    } catch (e, s) {
      developer.log(
        'LỖI CHÍNH XÁC Ở DATA SOURCE (getHotelDetail)',
        error: e,
        stackTrace: s,
      );
      throw ServerException('Lỗi parse chi tiết khách sạn: $e');
    }
  }
}
