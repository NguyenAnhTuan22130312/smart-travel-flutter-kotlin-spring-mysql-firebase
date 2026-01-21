import 'dart:io';
import 'package:dio/dio.dart';
import '../../../data/models/ai/ai_destination_response.dart'; // Import model

class ChatRepository {
  final Dio _dio;
  final String baseUrl = "http://27.68.111.184:8080"; // Hoặc IP LAN

  ChatRepository(this._dio);

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/chat',
        data: { "message": message },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {"message": "Không có phản hồi từ Server", "recommendations": []};

    } catch (e) {
      throw Exception("Lỗi kết nối Chat AI: $e");
    }
  }

  Future<Map<String, dynamic>> sendImageToAI(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        '$baseUrl/api/v1/ai/search-image',
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Lỗi Server: ${response.statusCode}");
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }
}