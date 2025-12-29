import 'dart:io';
import 'package:dio/dio.dart';

class ChatRepository {
  final Dio _dio;

  final String baseUrl = "http://10.0.2.2:8080";

  ChatRepository(this._dio);

  Future<String> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/chat', // 👈 Thêm baseUrl vào đây
        data: {
          "message": message
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response.data['reply'];
    } catch (e) {
      throw Exception("Lỗi kết nối AI: $e");
    }
  }

  Future<String> sendImageToAI(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/api/v1/ai/search-image', // 👈 Quan trọng: Phải có baseUrl ở đây
        data: formData,
      );

      final data = response.data;

      // Xử lý dữ liệu trả về (giữ nguyên logic cũ)
      if (data['success'] == true) {
        String aiDetected = data['ai_detected'] ?? "Lạ";
        String category = data['mapped_category'] ?? "Không rõ";
        List<dynamic> places = data['data'] ?? [];

        StringBuffer buffer = StringBuffer();
        if (places.isNotEmpty) {
          buffer.writeln("Tìm thấy ${places.length} địa điểm phù hợp:");
          for (var place in places) {
            buffer.writeln("- ${place['name']} (${place['provinceName']})");
          }
        } else {
          buffer.writeln("Không tìm thấy địa điểm nào trong dữ liệu.");
        }

        return buffer.toString();
      } else {
        return "AI không nhận diện được ảnh này.";
      }

    } catch (e) {
      // In lỗi ra console để dễ debug
      print("Lỗi upload ảnh: $e");
      throw Exception("Lỗi gửi ảnh: $e");
    }
  }
}