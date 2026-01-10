import 'package:dio/dio.dart';
import 'package:smart_travel/data/models/comparison/comparison_models.dart'; // Import file model ở trên

class ComparisonRepository {
  final Dio _dio;
  // Lưu ý: Đổi IP nếu chạy máy thật (10.0.2.2 cho Emulator)
  final String baseUrl = "http://10.0.2.2:8080/api/v1/compare";

  ComparisonRepository(this._dio);

  // So sánh Tour
  Future<ComparisonResponse<TourComparisonModel>> compareTours(int id1, int id2) async {
    try {
      final response = await _dio.get('$baseUrl/tours', queryParameters: {'id1': id1, 'id2': id2});
      return ComparisonResponse.fromJson(
          response.data,
              (json) => TourComparisonModel.fromJson(json)
      );
    } catch (e) {
      throw Exception("Lỗi so sánh Tour: $e");
    }
  }

  // So sánh Hotel
  Future<ComparisonResponse<HotelComparisonModel>> compareHotels(int id1, int id2) async {
    try {
      final response = await _dio.get('$baseUrl/hotels', queryParameters: {'id1': id1, 'id2': id2});
      return ComparisonResponse.fromJson(
          response.data,
              (json) => HotelComparisonModel.fromJson(json)
      );
    } catch (e) {
      throw Exception("Lỗi so sánh Hotel: $e");
    }
  }
}